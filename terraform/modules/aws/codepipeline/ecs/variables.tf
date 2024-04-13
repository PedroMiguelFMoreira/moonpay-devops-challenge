variable "name" {
  description = "Name for the codepipeline and associated resources (e.g. Codebuild)"
  type        = string
}

variable "pipeline_type" {
  type    = string
  default = "V1"
}

variable "projects" {
  description = "The projects that will be built and deployed in the codepipeline"
  type        = list(string)
}

variable "custom_buildspec_path" {
  description = "Buildspec path"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = object({
    environment = string
    application = string
  })
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc" {
  description = "VPC Configuration"
  type        = object({
    id                 = string
    subnets            = list(string)
    security_group_ids = list(string)
  })
}

variable "github_config" {
  description = "Github configurations for codepipeline source stage"
  type        = object({
    connection_arn = string
    repository     = string
    branch         = string
    file_paths     = optional(object({
      includes = list(string)
      excludes = list(string)
    }))
    detect_changes = bool
  })
}

variable "custom_code_build_policies" {
  description = "Custom code build policies for IAM role"
  type        = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default = []
}

variable "custom_codebuild_timeout" {
  description = "Custom code build timeout"
  type        = string
  default     = "10"
}

variable "custom_codebuild_compute_type" {
  description = "Compute Type of Codebuild Project"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "custom_codebuild_image" {
  description = "Custom Codebuild image"
  type        = string
  default     = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
}

variable "custom_codebuild_type" {
  description = "Custom Codebuild type"
  type        = string
  default     = "ARM_CONTAINER"
}

variable "custom_codebuild_variables" {
  description = "Custom code build environment variables"
  type        = map(any)
  default     = {}
}

variable "codebuild_variables" {
  description = "ECS code build environment variables"
  type        = map(object({
    container_name           = string
    container_port           = number
    security_group           = string
    capacity_provider        = string
    capacity_provider_weight = number
  }))
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
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

variable "hasDeployStage" {
  type    = bool
  default = true
}