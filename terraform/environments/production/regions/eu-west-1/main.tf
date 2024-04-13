module "vpc" {
  source             = "./../../../../modules/aws/vpc"
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  tags               = {
    environment = var.environment
  }
}

module "codepipeline" {
  source                     = "./setup/codepipeline"
  account_id                 = var.account_id
  codepipeline_bucket_suffix = "moonpay"
  region                     = local.region
  subnets                    = module.vpc.public_subnets
  tags                       = {
    environment = var.environment
  }
  vpc_id = module.vpc.vpc_id
}

module "ecs" {
  source                      = "./setup/ecs"
  account_id                  = var.account_id
  artifact_bucket             = module.codepipeline.codepipeline_codepipeline_bucket_region
  codebuild_security_group_id = module.codepipeline.codepipeline_codebuild_security_group_id
  codedeploy_role_arn         = module.codepipeline.codepipeline_codedeploy_ecs_role_arn
  codepipeline_role_arn       = module.codepipeline.codepipeline_codepipeline_role_arn
  github_connection_arn       = var.ssh_github
  public_subnets              = module.vpc.public_subnets
  region                      = local.region
  tags                        = {
    environment = var.environment
  }
  vpc_id = module.vpc.vpc_id
}
