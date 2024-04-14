module "deepmerge" {
  source  = "Invicton-Labs/deepmerge/null"
  version = "0.1.5"
  # insert the 1 required variable here
  maps    = [
    local.projects_default, var.projects
  ]
}

locals {
  repository       = "PedroMiguelFMoreira/moonpay-devops-challenge"
  projects         = module.deepmerge.merged
  projects_default = {
    api = {
      name           = "api"
      container_port = 3000
      alb_port       = 3000
      desired_count  = 1
      cpu            = 1024
      memory         = 1024
      secret         = {
        description = "Configuration for moonpay api"
        values      = {
          POSTGRES_PRISMA_URL: "postgres://postgres:postgres@postgres:5432/currencies?schema=public"
        }
      }
    }
  }
}
