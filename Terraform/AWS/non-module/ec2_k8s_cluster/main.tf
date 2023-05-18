locals {
  additional_tags = {
    Terraform   = "true"
    Environment = var.environment
    Purpose     = var.purpose
    Owner       = var.owner
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = "192.169.0.0/16"

  tags = merge(
    {
      Name = "${var.namespace}-vpc"
    },
    local.additional_tags
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.169.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.namespace}-public-subnet"
    },
    local.additional_tags
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      Name = "${var.namespace}-igw"
    },
    local.additional_tags
  )
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = "${var.namespace}-public-rtb"
    },
    local.additional_tags
  )
}

resource "aws_route_table_association" "public_rtb_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "web_sg" {
  name   = "${var.namespace}-web-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.api_server_port
    to_port     = var.api_server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.etcd_client_port
    to_port     = var.etcd_client_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.etcd_peer_port
    to_port     = var.etcd_peer_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.kube_scheduler_port
    to_port     = var.kube_scheduler_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.kube_controller_manager_port
    to_port     = var.kube_controller_manager_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.kubelet_port
    to_port     = var.kubelet_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.kube_proxy_port
    to_port     = var.kube_proxy_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.kubectl_port
    to_port     = var.kubectl_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.namespace}-web-sg"
    },
    local.additional_tags
  )

}

data "aws_ami" "ubuntu" {
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

resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public_subnet.id

  user_data = base64encode(templatefile("${path.module}/user_data/kubeadm_master.tftpl", {}))

  tags = merge(
    {
      Name = "${var.namespace}-master"
    },
    local.additional_tags
  )

}

resource "aws_instance" "worker" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public_subnet.id

  user_data = base64encode(templatefile("${path.module}/user_data/kubeadm_worker.tftpl", {}))

  tags = merge(
    {
      Name = "${var.namespace}-worker"
    },
    local.additional_tags
  )

}