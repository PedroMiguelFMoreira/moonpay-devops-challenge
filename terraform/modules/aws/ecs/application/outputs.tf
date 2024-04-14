output "container" {
  value = {
    name                = aws_ecs_service.ecs_service.name
    container_port      = var.container_port
  }
}

output "load_balancer" {
  value = {
    listener_arn                 = aws_alb_listener.alb_listener.arn
    original_environment_name    = aws_alb_target_group.alb_target_group.*.name[0]
    original_environment_arn    = aws_alb_target_group.alb_target_group.*.arn[0]
    replacement_environment_name = aws_alb_target_group.alb_target_group.*.name[1]
    replacement_environment_arn = aws_alb_target_group.alb_target_group.*.arn[1]
  }
}

output "ec2_security_group" {
  value = module.ec2_security_group
}
