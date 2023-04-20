provider "aws" {
  region = var.region
}
data "aws_availability_zones" "available" {
  state = "available"
}
provider "tls" {
}


locals {
  additional_tags = {
    Terraform   = "true"
    Environment = var.environment
    Purpose     = var.purpose
    Owner       = var.owner
  }

  availability_zones = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))

  public_subnets = [
    for idx, cidr in var.public_subnet_cidrs : {
      cidr_block        = cidr
      availability_zone = local.availability_zones[idx]
    }
  ]

  private_subnets = [
    for idx, cidr in var.private_subnet_cidrs : {
      cidr_block        = cidr
      availability_zone = local.availability_zones[idx]
    }
  ]
}
data "aws_ami" "ubuntu_20_04" {
  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion_host" {
  for_each               = { for subnet in [try(local.public_subnets[0], null)] : format("public_subnet_%s", subnet.availability_zone) => subnet if length(var.public_subnet_cidrs) > 0 }
  ami                    = data.aws_ami.ubuntu_20_04.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet[each.key].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = merge(
    {
      Name = "${var.namespace}-bastion-host"
    },
    local.additional_tags
  )
}
