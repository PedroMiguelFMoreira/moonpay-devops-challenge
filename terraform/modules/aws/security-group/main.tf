resource "aws_security_group" "security_group" {
  name        = format("%s_%s", var.scope, var.name)
  description = format("%s_%s", var.scope, var.name)
  vpc_id      = var.vpc_id

  ingress = var.ingress
  egress  = var.egress

  tags = {
    managed_by  = "terraform"
    environment = var.tags.environment
    application = var.tags.application
  }

  lifecycle {
    create_before_destroy = true
  }
}