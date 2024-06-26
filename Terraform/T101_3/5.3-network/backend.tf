terraform {
  cloud {
    organization = "kane-org"         # 생성한 ORG 이름 지정
    hostname     = "app.terraform.io" # default

    workspaces {
      name = "network" # 없으면 생성됨
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.58"
    }
  }
  required_version = ">= 0.13"
}
