terraform {
  cloud {
    organization = "kane-org"         # 생성한 ORG 이름 지정
    hostname     = "app.terraform.io" # default

    workspaces {
      name = "terraform-stduy" # 없으면 생성됨
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

provider "aws" {
  region = "ap-northeast-2"
}

locals {
  name = var.name
}

resource "aws_iam_user" "myiamuser1" {
  name = "${local.name}1"
}

resource "aws_iam_user" "myiamuser2" {
  name = "${local.name}2"
}

variable "name" {
  default = "kane_test"
  type    = string
}
