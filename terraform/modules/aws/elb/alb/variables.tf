variable "vpc_id" {
  description = "Id of the VPC to be used"
  type        = string
}

variable "name" {
  description = "Name of the load balancer"
  type        = string
}

variable "subnets" {
  description = "IDs of all subnets to be used"
  type        = list(string)
}

variable "internal" {
  description = "Is the access to the application exclusively internal?"
  type        = bool
}

variable "idle_timeout" {
  description = "The time, in seconds, we will keep a connection open before timing it out"
  type        = number
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

