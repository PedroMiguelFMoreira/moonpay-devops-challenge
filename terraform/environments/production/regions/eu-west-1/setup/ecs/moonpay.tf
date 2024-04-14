module "moonpay" {
  source                       = "../../../../../../modules/projects/moonpay"
  account_id                   = var.account_id
  alb_id                       = module.alb_external_shared.alb_id
  alb_security_group           = module.alb_external_shared.alb_security_group
  application_name             = local.applications.moonpay.name
  artifact_bucket              = var.artifact_bucket
  capacity_provider_strategies = [
    {
      capacity_provider = module.ecs_capacity_provider.capacity_provider_name
      weight            = 100
    }
  ]
  cluster                     = module.ecs_cluster_europe.cluster
  codebuild_security_group_id = var.codebuild_security_group_id
  codedeploy_role_arn         = var.codedeploy_role_arn
  codepipeline_role_arn       = var.codepipeline_role_arn
  github_config               = {
    connection_arn = var.github_connection_arn
    branch         = "main"
  }
  ordered_placement_strategy = local.ordered_placement_strategy.pack_cpu
  projects                   = local.applications.moonpay.projects
  rds_security_group_id      = var.moonpay_rds_security_group_id
  region                     = var.region
  subnets                    = var.public_subnets
  tags                       = var.tags
  vpc_id                     = var.vpc_id
}