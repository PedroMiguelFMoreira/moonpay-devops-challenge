output "ec2_security_group" {
  value = module.ec2_security_group
}

output "capacity_provider_name" {
  value = aws_ecs_capacity_provider.capacity_provider.name
}

output "cluster_name" {
  value = var.cluster_name
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.autoscaling_group.name
}
