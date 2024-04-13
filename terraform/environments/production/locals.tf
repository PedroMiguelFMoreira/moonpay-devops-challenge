locals {
  region      = "eu-west-1"
  environment = "production"
  account_id  = data.aws_caller_identity.current.account_id
}
