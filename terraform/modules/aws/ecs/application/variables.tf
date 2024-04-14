variable "alb_id" {
  description = "ALB ID to be used"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "cluster_id" {
  description = "Id of the cluster"
  type        = string
}

variable "name" {
  description = "Name of the application project"
  type        = string
}

variable "application_name" {
  description = "Name of the application"
  type        = string
}

variable "vpc_id" {
  description = "Id of the VPC to be used"
  type        = string
}

variable "subnets" {
  description = "IDs of all subnets to be used"
  type        = list(string)
}

variable "image_url" {
  description = "URL to the image"
  type        = string
}

variable "alb_port" {
  description = "Port used to forward alb traffic"
  type        = number
}

variable "container_port" {
  description = "Port where the application will run"
  type        = number
}

variable "healthcheck" {
  description = "Healthcheck for application"
  nullable    = false
  type        = object({
    alb = object({
      path                = string
      interval            = number
      unhealthy_threshold = number
    })
    container = object({
      retries     = number
      timeout     = number
      interval    = number
      startPeriod = number
      command     = string
    })
  })
  default = {
    alb = {
      path                = "/"
      interval            = 30
      unhealthy_threshold = 3
    }
    container = {
      retries     = 5
      timeout     = 5
      interval    = 5
      startPeriod = 30
      command     = null
    }
  }
}

variable "volumes" {
  description = "List of persistent volumes to be cenas e coisas"
  type        = list(object({
    id              = string
    name            = string
    access_point_id = string
  }))
  default = []
}

variable "container_definitions" {
  description = "This object can add or override the default container definitions"
  type        = object({
    linuxParameters = optional(object({
      initProcessEnabled = optional(bool)
    }))
    entrypoint  = optional(list(string))
    mountPoints = optional(list(object({
      readOnly      = bool
      containerPath = string
      sourceVolume  = string
    })))
  })
  default = {
    linuxParameters = null
    entrypoint      = null
    mountPoints     = null
  }
}

variable "alb_protocol" {
  description = "Load balancer protocol"
  type        = string
  default     = "HTTP"
}

variable "certificate_arn" {
  description = "Arn of the SSL certificate, required for HTTPS protocol"
  type        = string
  default     = ""
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
}

variable "deployment_configuration" {
  description = "ECS service deployment configuration"
  type        = object({
    controller              = string
    maximum_percent         = number
    minimum_healthy_percent = number
  })
  default = {
    controller              = "CODE_DEPLOY"
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }
}

variable "cpu" {
  description = "Amount of cpu to reserve for the application"
  type        = number
}

variable "memory" {
  description = "Amount of memory to reserve for the application"
  type        = number
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

variable "inline_policies" {
  description = "List of inline policies that are used for iam_role in task definition"
  type        = list(object({
    version   = string
    name      = string
    statement = list(object({
      Action   = list(string)
      Effect   = string
      Resource = list(string)
    }))
  }))
}

variable "environment" {
  description = "List of environment variables to add to the task definition"
  type        = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets_values" {
  description = "List of secrets to add to the task definition"
  type        = list(object({
    valueFrom = string
    name      = string
  }))
}

variable "placement_constraints" {
  type = list(object({
    type       = string
    expression = string
  }))
  default = []
}

variable "capacity_provider_strategies" {
  type = list(object({
    capacity_provider = string
    weight            = number
  }))
}

variable "ordered_placement_strategy" {
  type = list(object({
    type  = string
    field = string
  }))
}
