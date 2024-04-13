resource "aws_default_vpc" "default_vpc" {
  tags = merge(var.tags{
    Name        = "Default VPC"
    environment = var.tags.environment
    managed_by  = "terraform"
  })
}

resource "aws_default_subnet" "default_subnet" {
  for_each = toset(var.availability_zones)
  availability_zone = each.value

  tags = {
    Name        = format("Default subnet for %s", each.value)
    environment = var.tags.environment
    managed_by  = "terraform"
  }
}

resource "aws_subnet" "private_ecs_az1" {
  for_each = toset(var.availability_zones)

  tags = {
    Name        = "Private ECS - A"
    managed_by  = "terraform"
    environment = var.tags.environment
  }
  cidr_block        = var.cidr_blocks.private.subnets.d.cidr_block
  vpc_id            = aws_vpc.vpc.id
  availability_zone = format("%sa", var.region)
  depends_on        = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr
  ]
}

resource "aws_subnet" "private_ecs_az2" {
  tags = {
    Name        = "Private ECS - B"
    managed_by  = "terraform"
    environment = var.tags.environment
  }
  cidr_block        = var.cidr_blocks.private.subnets.e.cidr_block
  vpc_id            = aws_vpc.vpc.id
  availability_zone = format("%sb", var.region)
  depends_on        = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr
  ]
}

resource "aws_subnet" "private_ecs_az3" {
  tags = {
    Name        = "Private ECS - C"
    managed_by  = "terraform"
    environment = var.tags.environment
  }
  cidr_block        = var.cidr_blocks.private.subnets.f.cidr_block
  vpc_id            = aws_vpc.vpc.id
  availability_zone = format("%sc", var.region)
  depends_on        = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr
  ]
}

resource "aws_route_table" "private_ecs_subnet_rt" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    Name        = "Private ECS Subnet RT"
    managed_by  = "terraform"
    environment = var.tags.environment
  }

  depends_on = [
    aws_subnet.private_ecs_az1,
    aws_subnet.private_ecs_az2,
    aws_subnet.private_ecs_az3
  ]
}

resource "aws_vpc_endpoint_route_table_association" "ecs_s3_route" {
  route_table_id  = aws_route_table.private_ecs_subnet_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.vpc_endpoint_s3.id
}

resource "aws_vpc_endpoint_route_table_association" "ecs_dynamodb_route" {
  route_table_id  = aws_route_table.private_ecs_subnet_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.vpc_endpoint_dynamodb.id
}

resource "aws_route" "ecs_nat_gateway_route" {
  route_table_id         = aws_route_table.private_ecs_subnet_rt.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_ecs_subnet_az1_association" {
  route_table_id = aws_route_table.private_ecs_subnet_rt.id
  subnet_id      = aws_subnet.private_ecs_az1.id
}

resource "aws_route_table_association" "private_ecs_subnet_az2_association" {
  route_table_id = aws_route_table.private_ecs_subnet_rt.id
  subnet_id      = aws_subnet.private_ecs_az2.id
}

resource "aws_route_table_association" "private_ecs_subnet_az3_association" {
  route_table_id = aws_route_table.private_ecs_subnet_rt.id
  subnet_id      = aws_subnet.private_ecs_az3.id
}

