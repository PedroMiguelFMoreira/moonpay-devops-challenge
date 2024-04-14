variable "name" {
  description = "Name of the secret"
  type        = string
}

variable "description" {
  description = "Description of the secret"
  type        = string
}

variable "secret" {
  description = "JSON object containing the secret values"
  type        = map(string)
}

variable "tags" {
  description = "Tags to be applied to the secret"
  type        = object({
    environment = string
    application = string
  })
}