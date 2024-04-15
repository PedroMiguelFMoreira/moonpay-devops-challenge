resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name        = "Default VPC"
    environment = var.tags.environment
    managed_by  = "terraform"
  }
}

resource "aws_default_subnet" "default_subnet" {
  for_each          = toset(var.public_availability_zones)
  availability_zone = each.value

  tags = {
    Name        = format("Default subnet for %s", each.value)
    environment = var.tags.environment
    managed_by  = "terraform"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each          = var.private_availability_zones
  availability_zone = each.key
  cidr_block        = each.value
  tags              = {
    Name        = format("Default subnet for %s", each.key)
    environment = var.tags.environment
    managed_by  = "terraform"
  }
  vpc_id = aws_default_vpc.default_vpc.id
}


resource "aws_route_table" "private_subnet_rt" {
  vpc_id = aws_default_vpc.default_vpc.id
  tags   = {
    Name        = "Private Subnet RT"
    managed_by  = "terraform"
    environment = var.tags.environment
  }
}

resource "aws_eip" "default_vpc_eip" {
  domain = "vpc"
  tags   = {
    Name        = "Private Subnet NAT"
    environment = var.tags.environment
    managed_by  = "terraform"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = aws_subnet.private_subnet[element(var.public_availability_zones, 0)].id
  allocation_id = aws_eip.default_vpc_eip.id
  tags          = {
    Name        = "Private Subnet NAT"
    managed_by  = "terraform"
    environment = var.tags.environment
  }
}

resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.private_subnet_rt.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_subnet_association" {
  for_each       = toset(keys(var.private_availability_zones))
  route_table_id = aws_route_table.private_subnet_rt.id
  subnet_id      = aws_subnet.private_subnet[each.key].id
}
