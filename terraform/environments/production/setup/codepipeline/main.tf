resource "aws_s3_bucket" "codepipeline_bucket_region" {
  bucket = format("codepipeline.%s.%s", var.region, var.codepipeline_bucket_suffix)
  tags   = {
    managed_by  = "terraform"
    environment = var.tags.environment
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_bucket_region_lifecycle_configuration" {
  bucket = aws_s3_bucket.codepipeline_bucket_region.bucket
  rule {
    id     = "delete 6-month-old versions"
    status = "Enabled"
    expiration {
      expired_object_delete_marker = true
    }
    noncurrent_version_expiration {
      noncurrent_days = 180
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_codestarconnections_connection" "codepipeline_github_connection" {
  name          = "GitHubRepositoryConnection"
  provider_type = "GitHub"

  tags = {
    managed_by  = "terraform"
    environment = var.tags.environment
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = format("codepipeline-role-%s", var.region)
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    managed_by  = "terraform"
    environment = var.tags.environment
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ],
        Resource = [
          aws_s3_bucket.codepipeline_bucket_region.arn,
          "${aws_s3_bucket.codepipeline_bucket_region.arn}/*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codestar-connections:UseConnection",
        ],
        Resource = aws_codestarconnections_connection.codepipeline_github_connection.arn
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecs:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource  = "*",
        Condition = {
          "StringLike" = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "codedeploy_ecs_role" {
  name                = format("codedeploy-ecs-role-%s", var.region)
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS",
  ]
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        },
      }
    ]
  })

  tags = {
    managed_by  = "terraform"
    environment = var.tags.environment
  }
}

module "codebuild_security_group" {
  source = "../../../../modules/aws/security-group"
  scope  = "codebuild"
  name   = "default"
  vpc_id = var.vpc_id
  tags = {
    environment = var.tags.environment
    application = "pipelines"
  }
}
