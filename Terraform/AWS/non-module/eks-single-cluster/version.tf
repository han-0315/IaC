terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.58"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }

  required_version = ">= 0.13"
}
