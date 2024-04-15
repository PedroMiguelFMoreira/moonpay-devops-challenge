variable "public_availability_zones" {
  description = "List of public availability zones"
  type        = list(string)
}

variable "private_availability_zones" {
  description = "List of private availability zones"
  type        = map(string)
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = object({
    environment = string
  })
}