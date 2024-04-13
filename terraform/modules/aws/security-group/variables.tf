variable "scope" {
  description = "Scope of this security group (e.g. EC2, LB)"
  type        = string
}
variable "name" {
  description = "Name of the application/service related to this security group"
  type        = string
}

variable "vpc_id" {
  description = "Id of the VPC the security group belongs to"
  type = string
}

variable "ingress" {
  description = "Ingress rules"
  type = list(any)
  default = null
}

variable "egress" {
  description = "Egress rules"
  type    = list(any)
  default = [
    {
      description      = ""
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      self             = false
    }
  ]
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = object({
    environment = string
    application = string
  })
}
