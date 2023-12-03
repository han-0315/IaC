output "aws_vpc_id" {
  value = aws_vpc.kane_vpc.id
}
output "aws_subnet_id" {
  value = aws_subnet.kane_subnet.id
}
output "aws_security_group_id" {
  value = aws_security_group.kane_sg.id
}

