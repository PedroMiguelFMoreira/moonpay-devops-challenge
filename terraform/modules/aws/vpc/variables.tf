variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = object({
    environment = string
  })
}