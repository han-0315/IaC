
locals {
  additional_tags = {
    Terraform   = "true"
    Environment = "Dev"
    Purpose     = "Test"
    Owner       = "Kane"
  }
}


resource "aws_vpc" "kane_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "t101-study"
  }
}

resource "aws_subnet" "kane_subnet1" {
  vpc_id     = aws_vpc.kane_vpc.id
  cidr_block = "10.10.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "t101-subnet1"
  }
}

resource "aws_subnet" "kane_subnet2" {
  vpc_id     = aws_vpc.kane_vpc.id
  cidr_block = "10.10.2.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "t101-subnet2"
  }
}


resource "aws_internet_gateway" "kane_igw" {
  vpc_id = aws_vpc.kane_vpc.id

  tags = {
    Name = "t101-igw"
  }
}

resource "aws_route_table" "kane_rt" {
  vpc_id = aws_vpc.kane_vpc.id

  tags = {
    Name = "t101-rt"
  }
}

resource "aws_route_table_association" "kane_rtassociation1" {
  subnet_id      = aws_subnet.kane_subnet1.id
  route_table_id = aws_route_table.kane_rt.id
}

resource "aws_route_table_association" "kane_rtassociation2" {
  subnet_id      = aws_subnet.kane_subnet2.id
  route_table_id = aws_route_table.kane_rt.id
}

resource "aws_route" "kane_defaultroute" {
  route_table_id         = aws_route_table.kane_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.kane_igw.id
}

output "aws_vpc_id" {
  value = aws_vpc.kane_vpc.id
}
resource "aws_security_group" "kane_sg" {
  vpc_id      = aws_vpc.kane_vpc.id
  name        = "T101 SG"
  description = "T101 Study SG"
}

resource "aws_security_group_rule" "kane_sginbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kane_sg.id
}

resource "aws_security_group_rule" "kane_sgoutbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kane_sg.id
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

resource "aws_instance" "kane_ec2" {

  depends_on = [
    aws_internet_gateway.kane_igw
  ]

  ami                         = data.aws_ami.amazonlinux2.id
  associate_public_ip_address = true
  instance_type               = var.ec2_instance_type
  vpc_security_group_ids      = ["${aws_security_group.kane_sg.id}"]
  subnet_id                   = aws_subnet.kane_subnet1.id

  user_data = <<-EOF
              #!/bin/bash
              wget https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
              mv busybox-x86_64 busybox
              chmod +x busybox
              RZAZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone-id)
              IID=$(curl 169.254.169.254/latest/meta-data/instance-id)
              LIP=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
              echo "<h1>RegionAz($RZAZ) : Instance ID($IID) : Private IP($LIP) : Web Server</h1>" > index.html
              nohup ./busybox httpd -f -p 80 &
              EOF

  user_data_replace_on_change = true

  tags = merge({
    Name = "t101-kane_ec2"
    }
  , local.additional_tags)
}

output "kane_ec2_public_ip" {
  value       = aws_instance.kane_ec2.public_ip
  description = "The public IP of the Instance"
}
