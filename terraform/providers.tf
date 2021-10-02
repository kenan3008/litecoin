terraform {
  required_version = "1.0.8"

  backend "s3" {
    bucket         = "devops-terraform-state"
    region         = "eu-central-1"
    key            = "tfstate/dev/role_test.tfstate"
    profile        = "tf-devops-dev"
    dynamodb_table = "terraform-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.60.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region  = "eu-central-1"
  profile = "tf-devops-dev"
}
