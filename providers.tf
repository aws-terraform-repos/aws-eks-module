# Terraform and provider version requirements
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  # Configuration will be taken from:
  # - Environment variables (AWS_PROFILE, AWS_REGION, etc.)
  # - AWS credentials file (~/.aws/credentials)
  # - IAM role (if running on EC2)

  default_tags {
    tags = {
      ManagedBy = "terraform"
      Module    = "aws-eks-module"
    }
  }
}
