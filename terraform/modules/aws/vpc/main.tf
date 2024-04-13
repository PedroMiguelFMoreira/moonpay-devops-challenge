resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name        = "Default VPC"
    environment = var.tags.environment
    managed_by  = "terraform"
  }
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
