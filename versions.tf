
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Give resources a common project tag.
  default_tags {
    tags = {
      Project = "itmo-444-544-lab07"
    }
  }
}
