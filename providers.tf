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
  region = "eu-west-1"
  default_tags {
    tags = {
      environment       = "lab"
      service           = "baseline-infrastructure"
      stage             = "seed"
      repository        = "github/cloud-lab-iac"
      tf-state-location = local.state_location
      tf-workspace      = terraform.workspace
    }
  }
}

provider "aws" {
  alias  = "replica"
  region = "eu-central-1"
}
