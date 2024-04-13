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