module "ec2_security_group" {
  source = "../../security-group"
  scope  = "ecs_ec2"
  name   = local.identifier
  vpc_id = var.vpc_id
  tags   = {
    environment = var.tags.environment
    application = var.cluster_name
  }
}

resource "aws_iam_role" "iam_role" {
  name               = "${local.identifier}_instance"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ]
  tags = merge(
    { managed_by = "terraform" },
    var.tags
  )
}

resource "aws_iam_role_policy" "ec2_access_policy" {
  name   = "ec2_access_policy"
  role   = aws_iam_role.iam_role.name
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateTags"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_access_policy" {
  name   = "ecs_access_policy"
  role   = aws_iam_role.iam_role.name
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:ListServices",
          "ecs:ListContainerInstances",
          "ecs:ListClusters",
          "ecs:DescribeServices",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeClusters"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecr_access_policy" {
  name   = "ecr_access_policy"
  role   = aws_iam_role.iam_role.name
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${local.identifier}_agent"
  role = aws_iam_role.iam_role.name
  tags = merge(
    { managed_by = "terraform" },
    var.tags
  )
}

resource "aws_launch_template" "launch_template" {
  name          = "${local.identifier}_ec2_launch_template"
  description   = "This is the ${var.name} template to start EC2 instances for the ${local.identifier} ECS Cluster"
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = base64encode(templatefile("${path.module}/init.tpl", {
    instance_prefix = "ecs_${local.identifier}_capacity_provider",
    cluster_name    = var.cluster_name
  }))
  update_default_version = false
  iam_instance_profile {
    arn = aws_iam_instance_profile.iam_instance_profile.arn
  }
  ebs_optimized = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      iops                  = 3000
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [module.ec2_security_group.security_group_id]
  }

  tags = merge(
    { managed_by = "terraform" },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "ecs_${local.identifier}_autoscaling_group"
  min_size                  = 0
  desired_capacity          = 0
  max_size                  = 0
  vpc_zone_identifier       = var.subnets
  health_check_grace_period = 300
  health_check_type         = "EC2"
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
      instance_warmup        = 300
    }
  }
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
  dynamic "tag" {
    for_each = merge(
      { managed_by = "terraform" },
      {
        for key, value in var.tags : key => value if value != null
      },
    )
    content {
      key                 = tag.key
      propagate_at_launch = true
      value               = tag.value
    }
  }
  lifecycle {
    ignore_changes = [desired_capacity, min_size, max_size]
  }
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "${local.identifier}_capacity_provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.autoscaling_group.arn
    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
  tags = merge(
    { managed_by = "terraform" },
    var.tags
  )
}
