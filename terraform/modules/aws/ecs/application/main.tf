module "ec2_security_group" {
  source = "../../security-group"
  scope  = "ecs_ec2"
  name   = var.name
  vpc_id = var.vpc_id
  tags   = var.tags
}

resource "aws_alb_target_group" "alb_target_group" {
  count                         = length(local.target_groups)
  name                          = format("%s-%s-tg", substr(var.name, 0, 23), element(local.target_groups, count.index))
  port                          = var.container_port
  protocol                      = "HTTP"
  vpc_id                        = var.vpc_id
  target_type                   = "ip"
  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    protocol            = "HTTP"
    path                = var.healthcheck.alb.path
    interval            = var.healthcheck.alb.interval
    unhealthy_threshold = var.healthcheck.alb.unhealthy_threshold
  }
  tags = merge(
    { managed_by = "terraform" },
    var.tags
  )
}

resource "aws_alb_listener" "alb_listener" {
  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
  load_balancer_arn = var.alb_id
  port              = var.alb_port
  protocol          = var.alb_protocol
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.*.arn[0]
  }
  tags = merge(
    { managed_by = "terraform" },
    var.tags
  )
}

resource "aws_lb_listener_rule" "alb_listener_rule" {
  count = 1
  lifecycle {
    ignore_changes = [
      action
    ]
  }
  listener_arn = aws_alb_listener.alb_listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group[0].arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_iam_role" "iam_role_task_definition" {
  name               = format("%s-task-definition-%s", substr(var.name, 0, 38), var.region)
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  dynamic "inline_policy" {
    for_each = concat(local.default_inline_policies, var.inline_policies)
    content {
      name   = inline_policy.value["name"]
      policy = jsonencode({
        Version   = inline_policy.value["version"]
        Statement = inline_policy.value["statement"]
      })
    }
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
  tags = merge(
    { managed_by = "terraform" },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = format("/application/%s", var.application_name)
  retention_in_days = 30
  tags              = merge(
    { managed_by = "terraform" },
    var.tags
  )
}

resource "aws_cloudwatch_log_metric_filter" "cloudwatch_log_metric_filter" {
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name
  name           = "LogLevels"
  pattern        = "{ $.application = \"*\" }"
  metric_transformation {
    name       = "LogLevels"
    namespace  = "LogStats"
    value      = "1"
    dimensions = {
      Application = "$.application"
      LogLevel    = "$.logLevel"
    }
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family             = var.name
  execution_role_arn = aws_iam_role.iam_role_task_definition.arn
  task_role_arn      = aws_iam_role.iam_role_task_definition.arn
  cpu                = var.cpu
  memory             = var.memory
  network_mode       = "awsvpc"
  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value["name"]

      efs_volume_configuration {
        file_system_id     = volume.value["id"]
        transit_encryption = "ENABLED"
        authorization_config {
          iam             = "ENABLED"
          access_point_id = volume.value["access_point_id"]
        }
      }
    }
  }
  container_definitions = jsonencode([
    merge({
      name         = var.name
      image        = format("%s:latest", var.image_url)
      cpu          = var.cpu
      memory       = var.memory
      essential    = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      healthCheck = {
        retries = var.healthcheck.container.retries
        command = [
          "CMD-SHELL",
          var.healthcheck.container.command != null ? var.healthcheck.container.command : "wget --no-verbose --tries=1 --spider http://localhost:${var.container_port}${var.healthcheck.alb.path} || exit 1"
        ]
        timeout : var.healthcheck.container.timeout
        interval : var.healthcheck.container.interval
        startPeriod : var.healthcheck.container.startPeriod
      }
      environment      = var.environment
      secrets          = var.secrets_values
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          awslogs-group         = format("/application/%s", var.application_name)
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs-service"
        }
      }
    }, var.container_definitions)
  ])
  tags = merge(
    { managed_by = "terraform" },
    var.tags
  )
  skip_destroy = true
}

resource "aws_ecs_service" "ecs_service" {
  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer,
      placement_constraints
    ]
  }
  name                               = var.name
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count                      = var.desired_count
  force_new_deployment               = false
  propagate_tags                     = "SERVICE"
  deployment_maximum_percent         = var.deployment_configuration.maximum_percent
  deployment_minimum_healthy_percent = var.deployment_configuration.minimum_healthy_percent
  deployment_controller {
    type = var.deployment_configuration.controller
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategies
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  load_balancer {
    container_name   = var.name
    container_port   = var.container_port
    target_group_arn = aws_alb_target_group.alb_target_group[0].arn
  }

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [
      module.ec2_security_group.security_group_id
    ]
    assign_public_ip = false
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy
    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  tags = merge(
    { managed_by = "terraform" },
    var.tags
  )

  depends_on = [aws_alb_listener.alb_listener]
}
