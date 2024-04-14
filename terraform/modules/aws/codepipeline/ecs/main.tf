resource "aws_ecr_repository" "ecr_repository" {
  for_each = toset(var.projects)

  name                 = format("%s_%s", var.name, each.value)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    managed_by  = "terraform"
    environment = var.tags.environment
    application = var.tags.application
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_repository_policy" {
  for_each = toset(var.projects)

  repository = format("%s_%s", var.name, each.value)

  depends_on = [aws_ecr_repository.ecr_repository]
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 2 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 2
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_iam_role" "codebuild_role" {
  for_each            = toset(var.projects)
  name                = format("%s_%s-%s", var.name, each.value, var.region)
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
  ]
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    managed_by  = "terraform"
    environment = var.tags.environment
    application = var.tags.application
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  for_each = toset(var.projects)

  name = format("%s_%s", var.name, each.value)
  role = aws_iam_role.codebuild_role[each.value].name

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ],
        Resource = [
          var.artifact_bucket.arn,
          "${var.artifact_bucket.arn}/*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterfacePermission"
        ],
        Resource  = format("arn:aws:ec2:%s:%s:network-interface/*", var.region, var.account_id),
        Condition = {
          "StringEquals" = {
            "ec2:Subnet" = [
              for subnet in var.vpc.subnets : format("arn:aws:ec2:%s:%s:subnet/%s", var.region, var.account_id, subnet)
            ],
            "ec2:AuthorizedService" = "codebuild.amazonaws.com"
          }
        }
      },
      {
        Effect : "Allow"
        Action = [
          "ecs:DescribeTaskDefinition"
        ]
        Resource = "*"
      }
    ], var.custom_code_build_policies)
  })
}

resource "aws_cloudwatch_log_group" "codebuild_log_group" {
  for_each = toset(var.projects)

  name              = format("/aws/codebuild/%s_%s", var.name, each.value)
  retention_in_days = 7

  tags = {
    managed_by  = "terraform"
    environment = var.tags.environment
    application = var.tags.application
  }
}

resource "aws_codepipeline" "codepipeline" {
  name          = format("%s", var.name)
  pipeline_type = var.pipeline_type
  role_arn      = var.codepipeline_role_arn

  artifact_store {
    location = var.artifact_bucket.bucket
    type     = "S3"
  }

  dynamic trigger {
    for_each = var.pipeline_type == "V2" ? ["1"] : []
    content {
      provider_type = "CodeStarSourceConnection"
      git_configuration {
        source_action_name = "Source"
        push {
          branches {
            includes = [var.github_config.branch]
          }
          file_paths {
            includes = var.github_config.file_paths.includes
            excludes = var.github_config.file_paths.excludes
          }
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      category         = "Source"
      name             = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.github_config.connection_arn
        FullRepositoryId = var.github_config.repository
        BranchName       = var.github_config.branch
        DetectChanges    = var.github_config.detect_changes
      }
    }
  }

  dynamic "stage" {
    for_each = var.tags.environment == "production" ? ["1"] : []
    content {
      name = "Approve"
      action {
        category = "Approval"
        name     = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"
      }
    }
  }

  stage {
    name = "Build"

    dynamic "action" {
      for_each = var.projects

      content {
        category         = "Build"
        name             = action.value
        owner            = "AWS"
        provider         = "CodeBuild"
        version          = "1"
        input_artifacts  = ["source_output"]
        output_artifacts = [format("build_output_%s", action.value)]
        configuration    = {
          ProjectName = aws_codebuild_project.codebuild_project[action.value].name
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.hasDeployStage == true ? ["Deploy"] : []
    content {
      name = "Deploy"
      dynamic "action" {
        for_each = var.projects
        content {
          category        = "Deploy"
          name            = action.value
          owner           = "AWS"
          provider        = "ECS"
          version         = "1"
          input_artifacts = [format("build_output_%s", action.value)]
          configuration   = {
            ClusterName = var.cluster_name
            ServiceName = format("%s-%s", var.name, action.value)
          }
        }
      }
    }
  }

  tags = {
    managed_by  = "terraform"
    environment = var.tags.environment
    application = var.tags.application
  }
}

resource "aws_codebuild_project" "codebuild_project" {
  for_each = toset(var.projects)

  name          = format("%s_%s", var.name, each.value)
  build_timeout = var.custom_codebuild_timeout
  service_role  = aws_iam_role.codebuild_role[each.value].arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = format("%s/%s/cache", var.artifact_bucket.id, each.value)
  }

  vpc_config {
    vpc_id             = var.vpc.id
    subnets            = var.vpc.subnets
    security_group_ids = var.vpc.security_group_ids
  }

  environment {
    compute_type    = var.custom_codebuild_compute_type
    image           = var.custom_codebuild_image
    type            = var.custom_codebuild_type
    privileged_mode = true

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.tags.environment
    }
    environment_variable {
      name  = "PROJECT_NAME"
      value = each.value
    }
    environment_variable {
      name  = "REPOSITORY_URL"
      value = aws_ecr_repository.ecr_repository[each.value].repository_url
    }

    dynamic "environment_variable" {
      for_each = var.codebuild_variables[each.value]
      content {
        name  = upper(environment_variable.key)
        value = environment_variable.value
      }
    }
    environment_variable {
      name  = "TASK_DEFINITION"
      value = format("arn:aws:ecs:%s:%s:task-definition/%s", var.region, var.account_id, var.codebuild_variables[each.value].container_name)
    }

    dynamic "environment_variable" {
      for_each = var.custom_codebuild_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = format("/aws/codebuild/%s_%s", var.name, each.value)
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = length(var.projects) > 1 ? format("%s/buildspec.yml", var.custom_buildspec_path) : "buildspec.yml"
  }

  tags = {
    managed_by  = "terraform"
    environment = var.tags.environment
    application = var.tags.application
  }
}
