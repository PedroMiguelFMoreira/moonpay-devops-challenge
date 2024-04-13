module "alb_security_group" {
  source = "../../security-group"
  scope  = "alb"
  name   = var.name
  vpc_id = var.vpc_id
  tags   = var.tags
}

resource "aws_lb" "alb" {
  name                       = format("alb-%s", var.name)
  internal                   = var.internal
  load_balancer_type         = "application"
  security_groups            = module.alb_security_group[0].security_group_id
  subnets                    = var.subnets
  enable_deletion_protection = false
  idle_timeout               = var.idle_timeout
  tags                       = merge(
    { managed_by = "terraform" },
    var.tags
  )
}
