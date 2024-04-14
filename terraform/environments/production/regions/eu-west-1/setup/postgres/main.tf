resource "random_string" "db_instance_password" {
  length  = 16
  upper   = true
  numeric = true
  special = false
}

module "db_instance_security_group" {
  source = "../../../../../../modules/aws/security-group"
  scope  = "rds"
  name   = "postgres"
  vpc_id = var.vpc_id
  tags   = {
    environment = var.tags.environment
    application = "postgres"
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage           = "10"
  allow_major_version_upgrade = false
  apply_immediately           = false
  auto_minor_version_upgrade  = true
  availability_zone           = "eu-west-1a"
  engine                      = "postgres"
  engine_version              = "16.1"
  identifier                  = "postgres"
  instance_class              = "db.t4g.micro"
  network_type                = "IPV4"
  password                    = random_string.db_instance_password.result
  publicly_accessible         = false
  storage_encrypted           = true
  kms_key_id                  = data.aws_kms_key.ebs_kms_key.arn
  storage_type                = "gp3"
  username                    = "postgres"
  vpc_security_group_ids      = [module.db_instance_security_group.security_group_id]
  tags                        = {
    managed_by  = "terraform"
    environment = var.tags.environment
    application = "postgres"
  }
}
