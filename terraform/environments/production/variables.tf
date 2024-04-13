variable "pipeline" {
  description = "Determines if the plan is being ran in the pipeline or not"
  type        = bool
  default     = false
}

variable "ssh_github" {
  description = "SSH Key for the Github repository"
  type        = string
  default     = ""
}
