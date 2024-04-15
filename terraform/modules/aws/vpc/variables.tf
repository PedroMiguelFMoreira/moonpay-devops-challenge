variable "public_availability_zones" {
  description = "List of public availability zones"
  type        = list(string)
}

variable "private_availability_zones" {
  description = "List of private availability zones"
  type        = map(object({
    availability_zone = string
    cidr              = string
  }))
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = object({
    environment = string
  })
}