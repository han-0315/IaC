resource "aws_security_group" "bastion_sg" {
  name   = "${var.namespace}-bastion-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere. Should make this more restrictive.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.namespace}-bastion-sg"
    },
    local.additional_tags
  )
}
resource "aws_security_group" "cluster_sg" {
  name   = "${var.namespace}-cluster-sg"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      Name = "${var.namespace}-cluster-sg"
    },
    local.additional_tags
  )
}

resource "aws_security_group_rule" "cluster_sg_node_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.node_sg.id
  description              = "Node group communication with the cluster control plane"
}

resource "aws_security_group_rule" "cluster_sg_bastion_ingress" {
  type                     = "ingress"
  from_port                = var.ssh_port
  to_port                  = var.ssh_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
  description              = "Allow SSH access from the bastion host"
}
resource "aws_security_group" "node_sg" {
  name   = "${var.namespace}-node-sg"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      Name = "${var.namespace}-node-sg"
    },
    local.additional_tags
  )

}

resource "aws_security_group_rule" "node_sg_cluster_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.cluster_sg.id
  description              = "Cluster communication with the nodes"
}

resource "aws_security_group_rule" "node_sg_bastion_ingress" {
  type                     = "ingress"
  from_port                = var.ssh_port
  to_port                  = var.ssh_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
  description              = "Allow SSH access from the bastion host"
}
