variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "name" {
  description = "Capacity provider name"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "vpc_id" {
  description = "Id of the VPC to be used"
  type        = string
}

variable "ami_id" {
  description = "Id of the AMI to be used"
  type        = string
}

variable "subnets" {
  description = "IDs of all subnets to be used"
  type        = list(string)
}

variable "instance_type" {
  description = "Instance type to be used"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = object({
    environment = string
  })
}
