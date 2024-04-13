variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS Region"
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

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Public Subnets"
  type        = list(string)
}

variable "codebuild_security_group_id" {
  description = "Id of the security group for codebuild"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "codepipeline role arn"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "codedeploy role arn"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = object({
    environment = string
  })
}

variable "github_connection_arn" {
  description = "Github configurations"
  type        = string
}

/*

variable vpc_cidr_block {
  description = "Cidr block of the vpc"
  type        = list(string)
}

variable "nat_gateway_public_ipv4" {
  description = "IP of the network's NAT Gateway"
  type        = string
}

variable "ebs_kms_key_arn" {
  description = "EBS KMS key arn"
  type        = string
}

variable "rds_security_group_id" {
  description = "Security group of the RDS"
  type        = string
}
*/
