output "alb_security_group" {
  value = module.alb_security_group[0]
}

output "alb_id" {
  value = aws_lb.alb.id
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
