data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = ["${aws_default_vpc.default_vpc.id}"]
  }
}