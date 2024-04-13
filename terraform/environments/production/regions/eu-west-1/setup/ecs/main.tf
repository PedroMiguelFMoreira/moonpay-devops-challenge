module "ecs_capacity_provider" {
  source             = "../../../../../../modules/aws/ecs/capacity-provider"
  account_id         = var.account_id
  #	al2023-ami-ecs-hvm-2023.0.20231213-kernel-6.1-arm64
  ami_id             = "ami-0363ec71e897ecdbe"
  cluster_name       = "${var.region}-cluster"
  instance_type      = "c7g.xlarge"
  name               = "default"
  subnets            = var.public_subnets
  vpc_id             = var.vpc_id
  tags               = var.tags
}

module "ecs_cluster_europe" {
  source             = "../../../../../../modules/aws/ecs/cluster"
  capacity_providers = [
    module.ecs_capacity_provider.capacity_provider_name,
  ]
  cluster_name       = module.ecs_capacity_provider.cluster_name
  container_insights = "disabled"
  tags               = {
    environment = var.tags.environment
  }
}
