module "eu_west_1_infrastructure" {
  source    = "./regions/eu-west-1"
  providers = {
    aws        = aws
    aws.global = aws.global
  }
  account_id  = local.account_id
  environment = local.environment
  ssh_github  = replace(var.ssh_github, "/\\\\n/", "\n")
}
