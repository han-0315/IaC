locals {
  additional_tags = {
    Terraform   = "true"
    Environment = "Network"
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

resource "aws_subnet" "kane_subnet" {
  vpc_id            = aws_vpc.kane_vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "t101-subnet"
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
  subnet_id      = aws_subnet.kane_subnet.id
  route_table_id = aws_route_table.kane_rt.id
}

resource "aws_route" "kane_defaultroute" {
  route_table_id         = aws_route_table.kane_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.kane_igw.id
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
