variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "container_insights" {
  description = "Metrics about ECS containers"
  type        = string
  default     = "disabled"
}

variable "capacity_providers" {
  description = "List of capacity provider names available for cluster"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}
