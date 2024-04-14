variable "vpc_id" {
  description = "Id of the VPC the security group belongs to"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = object({
    environment = string
  })
}
