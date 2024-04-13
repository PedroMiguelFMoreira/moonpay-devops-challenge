variable "region" {
  description = "AWS Region"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "vpc_id" {
  description = "Id of the VPC that CodeBuild will use"
  type        = string
}

variable "codepipeline_bucket_suffix" {
  description = "Suffix to be appended to the s3 bucket"
  type        = string
}

variable "subnets" {
  description = "List of subnets that CodeBuild will use"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = object({
    environment = string
  })
}