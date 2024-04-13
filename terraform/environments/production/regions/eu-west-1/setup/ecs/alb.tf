module "alb_external_shared" {
  source       = "../../../../../../modules/aws/load-balancer/alb"
  name         = "external-ecs-shared"
  vpc_id       = var.vpc_id
  internal     = false
  idle_timeout = 60
  subnets      = var.public_subnets
  tags         = {
    environment = var.tags.environment
    application = "shared"
  }
}