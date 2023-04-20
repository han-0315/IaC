resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name = "${var.namespace}-vpc"
    },
    local.additional_tags
  )
}
resource "aws_subnet" "public_subnet" {
  for_each = { for subnet in local.public_subnets : format("public_subnet_%s", subnet.availability_zone) => subnet if length(var.public_subnet_cidrs) > 0 }

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name                     = format("%s-public-subnet-%s", var.namespace, split("-", each.value.availability_zone)[2])
      "kubernetes.io/role/elb" = 1
    },
    local.additional_tags
  )
}

resource "aws_subnet" "private_subnet" {
  for_each = { for subnet in local.private_subnets : format("private_subnet_%s", subnet.availability_zone) => subnet if length(var.private_subnet_cidrs) > 0 }

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name                              = format("%s-private-subnet-%s", var.namespace, split("-", each.value.availability_zone)[2])
      "kubernetes.io/role/internal-elb" = 1
    },
    local.additional_tags
  )
}
resource "aws_internet_gateway" "igw" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      Name = "${var.namespace}-igw"
    },
    local.additional_tags
  )
}
resource "aws_eip" "nat_eip" {
  for_each = { for subnet in var.single_nat_gateway ? [try(local.public_subnets[0], null)] : local.public_subnets : format("public_subnet_%s", subnet.availability_zone) => subnet if length(var.public_subnet_cidrs) > 0 && var.enable_nat_gateway }

  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    {
      Name = var.single_nat_gateway ? "${var.namespace}-nat-eip" : format("%s-nat-eip-%s", var.namespace, split("-", each.value.availability_zone)[2])
    },
    local.additional_tags
  )
}
resource "aws_nat_gateway" "nat" {
  for_each = { for subnet in var.single_nat_gateway ? [try(local.public_subnets[0], null)] : local.public_subnets : format("public_subnet_%s", subnet.availability_zone) => subnet if length(var.public_subnet_cidrs) > 0 && var.enable_nat_gateway }

  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.public_subnet[each.key].id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(
    {
      Name = var.single_nat_gateway ? "${var.namespace}-nat" : format("%s-nat-%s", var.namespace, split("-", each.value.availability_zone)[2])
    },
    local.additional_tags
  )
}
resource "aws_route_table" "public" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      Name = "${var.namespace}-public-rtb"
    },
    local.additional_tags
  )
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  for_each = { for subnet in local.public_subnets : format("public_subnet_%s", subnet.availability_zone) => subnet if length(var.public_subnet_cidrs) > 0 }

  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public[0].id
}
resource "aws_route_table" "private" {
  for_each = { for subnet in local.private_subnets : format("private_subnet_%s", subnet.availability_zone) => subnet if length(var.public_subnet_cidrs) > 0 && var.enable_nat_gateway && length(var.private_subnet_cidrs) > 0 }

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      Name = format("%s-private-rtb-%s", var.namespace, split("-", each.value.availability_zone)[2])
    },
    local.additional_tags
  )
}

resource "aws_route" "private_nat_gateway" {
  for_each = { for subnet in local.private_subnets : format("private_subnet_%s", subnet.availability_zone) => subnet if length(var.public_subnet_cidrs) > 0 && var.enable_nat_gateway && length(var.private_subnet_cidrs) > 0 }

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.nat[format("public_subnet_%s", local.public_subnets[0].availability_zone)].id : aws_nat_gateway.nat[format("public_subnet_%s", each.value.availability_zone)].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private" {
  #count          = length(var.private_subnets_cidr)
  for_each = { for subnet in local.private_subnets : format("private_subnet_%s", subnet.availability_zone) => subnet if length(var.public_subnet_cidrs) > 0 && var.enable_nat_gateway && length(var.private_subnet_cidrs) > 0 }

  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
