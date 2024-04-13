output "vpc_id" {
  value = aws_default_vpc.default_vpc.id
}

output "public_subnets" {
  value = aws_default_subnet.default_subnet.*.id
}