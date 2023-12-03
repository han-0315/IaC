
# # locals {
# #   additional_tags = {
# #     Terraform   = "true"
# #     Environment = "Dev"
# #     Purpose     = "Test"
# #     Owner       = "Kane"
# #   }
# # }


# # resource "aws_vpc" "kane_vpc" {
# #   cidr_block           = "10.10.0.0/16"
# #   enable_dns_support   = true
# #   enable_dns_hostnames = true

# #   tags = {
# #     Name = "t101-study"
# #   }
# # }

# # resource "aws_subnet" "kane_subnet1" {
# #   vpc_id     = aws_vpc.kane_vpc.id
# #   cidr_block = "10.10.1.0/24"

# #   availability_zone = "ap-northeast-2a"

# #   tags = {
# #     Name = "t101-subnet1"
# #   }
# # }

# # resource "aws_subnet" "kane_subnet2" {
# #   vpc_id     = aws_vpc.kane_vpc.id
# #   cidr_block = "10.10.2.0/24"

# #   availability_zone = "ap-northeast-2c"

# #   tags = {
# #     Name = "t101-subnet2"
# #   }
# # }


# # resource "aws_internet_gateway" "kane_igw" {
# #   vpc_id = aws_vpc.kane_vpc.id

# #   tags = {
# #     Name = "t101-igw"
# #   }
# # }

# # resource "aws_route_table" "kane_rt" {
# #   vpc_id = aws_vpc.kane_vpc.id

# #   tags = {
# #     Name = "t101-rt"
# #   }
# # }

# # resource "aws_route_table_association" "kane_rtassociation1" {
# #   subnet_id      = aws_subnet.kane_subnet1.id
# #   route_table_id = aws_route_table.kane_rt.id
# # }

# # resource "aws_route_table_association" "kane_rtassociation2" {
# #   subnet_id      = aws_subnet.kane_subnet2.id
# #   route_table_id = aws_route_table.kane_rt.id
# # }

# # resource "aws_route" "kane_defaultroute" {
# #   route_table_id         = aws_route_table.kane_rt.id
# #   destination_cidr_block = "0.0.0.0/0"
# #   gateway_id             = aws_internet_gateway.kane_igw.id
# # }

# # output "aws_vpc_id" {
# #   value = aws_vpc.kane_vpc.id
# # }
# # resource "aws_security_group" "kane_sg" {
# #   vpc_id      = aws_vpc.kane_vpc.id
# #   name        = "T101 SG"
# #   description = "T101 Study SG"
# # }

# # resource "aws_security_group_rule" "kane_sginbound" {
# #   type              = "ingress"
# #   from_port         = 80
# #   to_port           = 80
# #   protocol          = "tcp"
# #   cidr_blocks       = ["0.0.0.0/0"]
# #   security_group_id = aws_security_group.kane_sg.id
# # }

# # resource "aws_security_group_rule" "kane_sgoutbound" {
# #   type              = "egress"
# #   from_port         = 0
# #   to_port           = 0
# #   protocol          = "-1"
# #   cidr_blocks       = ["0.0.0.0/0"]
# #   security_group_id = aws_security_group.kane_sg.id
# # }
# # data "aws_ami" "amazonlinux2" {
# #   most_recent = true
# #   filter {
# #     name   = "owner-alias"
# #     values = ["amazon"]
# #   }

# #   filter {
# #     name   = "name"
# #     values = ["amzn2-ami-hvm-*-x86_64-ebs"]
# #   }

# #   owners = ["amazon"]
# # }

# # resource "aws_instance" "kane_ec2" {

# #   depends_on = [
# #     aws_internet_gateway.kane_igw
# #   ]

# #   ami                         = data.aws_ami.amazonlinux2.id
# #   associate_public_ip_address = true
# #   instance_type               = var.ec2_instance_type
# #   vpc_security_group_ids      = ["${aws_security_group.kane_sg.id}"]
# #   subnet_id                   = aws_subnet.kane_subnet1.id

# #   user_data_replace_on_change = true
# # }

# resource "terraform_data" "foo" {
#   triggers_replace = [
#     local_file.foo
#   ]
#   provisioner "local-exec" {
#     command = "echo 'terraform_data test'"
#   }
# }
# output "terraform_data_output" {
#   value = terraform_data.foo.output # 출력 결과는 "world"
# }


# variable "enable_file" {
#   default = true
# }

# resource "local_file" "foo" {
#   count    = var.enable_file ? 1 : 0
#   content  = "foo!"
#   filename = "${path.module}/foo.bar"
# }

# output "content" {
#   value = var.enable_file ? local_file.foo[0].content : ""
# }
