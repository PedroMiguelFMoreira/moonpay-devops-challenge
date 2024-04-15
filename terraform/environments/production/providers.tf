terraform {
  backend "remote" {
    organization = "moonpay-challenge"

    workspaces {
      name = "Production"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
  }

  required_version = ">= 1.7.4"
}

provider "aws" {
  profile = var.pipeline ? "" : "production"
  region  = local.region
}

provider "aws" {
  profile = var.pipeline ? "" : "production"
  alias   = "global"
  region  = "us-east-1"
}
