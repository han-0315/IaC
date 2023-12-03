locals {
  name = "mytest"
}

resource "aws_iam_user" "myiamuser1" {
  name = "${local.name}1"
}

resource "aws_iam_user" "myiamuser2" {
  name = "${local.name}2"
}
