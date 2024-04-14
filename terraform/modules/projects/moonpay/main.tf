module "moonpay_secretsmanager" {
  source      = "../../aws/secretsmanager"
  for_each    = local.projects
  description = each.value["secret"]["description"]
  name        = format("ecs-%s-%s", var.application_name, each.value["name"])
  secret      = each.value["secret"]["values"]
  tags        = {
    environment = var.tags.environment
    application = var.application_name
  }
}

module "moonpay" {
  source                       = "../../aws/ecs/application"
  for_each                     = local.projects
  alb_id                       = var.alb_id
  alb_port                     = each.value["alb_port"]
  application_name             = format("%s-%s", var.application_name, each.value["name"])
  capacity_provider_strategies = var.capacity_provider_strategies
  cluster_id                   = var.cluster.id
  container_port               = each.value["container_port"]
  cpu                          = each.value["cpu"]
  deployment_configuration     = {
    controller              = "ECS"
    maximum_percent         = 200
    minimum_healthy_percent = 0
  }
  desired_count   = each.value["desired_count"]
  image_url       = format("%s.dkr.ecr.%s.amazonaws.com/%s_%s", var.account_id, var.region, var.application_name, each.value["name"])
  inline_policies = [
    {
      name      = "secrets"
      version   = "2012-10-17"
      statement = [
        {
          Effect   = "Allow"
          Action   = ["secretsmanager:GetSecretValue"]
          Resource = [
            module.moonpay_secretsmanager[each.key].arn
          ]
        }
      ]
    },
  ]
  memory                     = each.value["memory"]
  name                       = format("%s-%s", var.application_name, each.value["name"])
  ordered_placement_strategy = var.ordered_placement_strategy
  subnets                    = var.subnets
  region                     = var.region
  secrets_values             = concat([
    for k, v in jsondecode(module.moonpay_secretsmanager[each.key].secret_string) : {
      valueFrom : format("%s:%s::", module.moonpay_secretsmanager[each.key].arn, k),
      name : k
    }
  ])
  tags = {
    environment = var.tags.environment
    application = var.application_name
  }
  vpc_id = var.vpc_id
}

module "moonpay_pipeline" {
  source = "../../aws/codepipeline/ecs"

  account_id          = var.account_id
  artifact_bucket     = var.artifact_bucket
  cluster_name        = var.cluster.name
  codebuild_variables = {
    for project, v in local.projects : project =>
    {
      container_name           = module.moonpay[project].container.name
      container_port           = module.moonpay[project].container.container_port
      security_group           = module.moonpay[project].ec2_security_group.security_group_id
      capacity_provider        = var.capacity_provider_strategies[0].capacity_provider
      capacity_provider_weight = var.capacity_provider_strategies[0].weight
    }
  }
  codedeploy_role_arn   = var.codedeploy_role_arn
  codepipeline_role_arn = var.codepipeline_role_arn
  github_config         = {
    connection_arn = var.github_config.connection_arn
    repository     = local.repository
    branch         = var.github_config.branch
    detect_changes = true
  }
  name     = var.application_name
  projects = keys(local.projects)
  region   = var.region
  tags     = {
    environment = var.tags.environment
    application = var.application_name
  }
  vpc = {
    id                 = var.vpc_id
    subnets            = var.subnets
    security_group_ids = [var.codebuild_security_group_id]
  }
}