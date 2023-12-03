
locals {
  additional_tags = {
    Terraform   = "true"
    Environment = "EC2"
  }
}
data "aws_ami" "amazonlinux2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

data "tfe_outputs" "network" {
  organization = "kane-org"
  workspace    = "network"
}
resource "aws_instance" "kane_ec2" {
  ami                         = data.aws_ami.amazonlinux2.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${data.tfe_outputs.network.values.aws_security_group_id}"]
  subnet_id                   = data.tfe_outputs.network.values.aws_subnet_id

  user_data_replace_on_change = true
}
