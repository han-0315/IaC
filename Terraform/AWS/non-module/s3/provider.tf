terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.58"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  profile = "default"
  region = var.region
}
