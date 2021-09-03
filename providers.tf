terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider (2 regions)
provider "aws" {
  alias = "principal"
  region = "eu-west-1"
}

provider "aws" {
  alias = "replica"
  region = "eu-central-1"
}
