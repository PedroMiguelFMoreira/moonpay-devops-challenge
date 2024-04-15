output "vpc_id" {
  value = aws_default_vpc.default_vpc.id
}

output "public_subnets" {
  value = [
    for subnet in aws_default_subnet.default_subnet : subnet.id
  ]
}

output "private_subnets" {
  value = [
    for subnet in aws_subnet.private_subnet : subnet.id
  ]
}
