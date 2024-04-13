

module "moonpay_pipeline" {
  source = "../../aws/codepipeline/ecs"

  account_id            = var.account_id
  artifact_bucket       = var.artifact_bucket
  cluster_name          = var.cluster.name
  codebuild_variables   = {
    for k, v in local.projects : k =>
    {
      container_name           = module.moonpay[k].container.name
      container_port           = module.moonpay[k].container.container_port
      security_group           = module.moonpay[k].ec2_security_group.security_group_id
      capacity_provider        = var.capacity_provider_strategies[0].capacity_provider
      capacity_provider_weight = var.capacity_provider_strategies[0].weight
    }
  }
  codedeploy_role_arn   = var.codedeploy_role_arn
  codepipeline_role_arn = var.codepipeline_role_arn
  github_config         = {    connection_arn = var.github_config.connection_arn
    repository     = local.repository
    branch         = var.github_config.branch
    detect_changes = true
  }
  name                  = var.application_name
  projects              = keys(local.projects)
  region                = var.region
  tags                  = {
    environment = var.tags.environment
    application = var.application_name
  }
  vpc = {
    id                 = var.vpc_id
    subnets            = var.subnets
    security_group_ids = [var.codebuild_security_group_id]
  }
}