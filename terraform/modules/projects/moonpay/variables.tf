variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "The name of the region where the application will run"
  type        = string
}

variable "application_name" {
  description = "Name of the application"
  type        = string
}

variable "vpc_id" {
  description = "Id of the VPC to be used"
  type        = string
}

variable "subnets" {
  description = "IDs of all the subnets to be used"
  type        = list(string)
}

variable "cluster" {
  description = "Cluster information"
  type        = object({
    id   = string
    name = string
  })
}

variable "alb_id" {
  description = "ALB ID to be used"
  type        = string
}

variable "alb_security_group" {
  description = "Security group of the LB"
  type        = object({
    security_group_id   = string
    security_group_name = string
  })
}

variable "github_config" {
  description = "Github configurations"
  type        = object({
    connection_arn = string
    branch         = string
  })
}

variable "artifact_bucket" {
  description = "S3 bucket to store the artifacts of codepipeline stages"
  type        = object({
    arn    = string
    id     = string
    bucket = string
  })
}

variable "codepipeline_role_arn" {
  description = "codepipeline role arn"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "codedeploy role arn"
  type        = string
}

variable "codebuild_security_group_id" {
  description = "Id of the security group for codebuild"
  type        = string
}

variable "projects" {
  description = "Custom projects configuration to be used by this application"
  type        = object({
    api = object({
      container_port = number
      alb_port       = number
      cpu            = number
      memory         = number
      desired_count  = number
    })
  })
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = object({
    environment = string
  })
}

/*
variable vpc_cidr_block {
  description = "Cidr block of the vpc"
}

variable "db_secretsmanager_secret_arn" {
  description = "Secret of the DB, so that we can have access to DB configs"
  type        = string
}

variable "db_security_group_id" {
  description = "Security group of the DB, so that we can have DB access"
  type        = string
}

variable "capacity_provider_strategies" {
  type = list(object({
    capacity_provider = string
    weight            = number
  }))
}

variable "ordered_placement_strategy" {
  type = list(object({
    type  = string
    field = string
  }))
}*/
