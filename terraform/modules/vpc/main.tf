resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_route_table" "routetable_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = var.routetable_cidr
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.public_subnet_1
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = var.public_subnet_map_public_ip_on_launch
}

resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.routetable_igw.id
}

resource "aws_subnet" "public_subnet2" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.public_subnet_2
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = var.public_subnet_map_public_ip_on_launch
}

resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.routetable_igw.id
}

resource "aws_eip" "nat_eip1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip2" {
  domain = "vpc"
}

resource "aws_subnet" "private_subnet1" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.private_subnet_1
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = var.private_subnet_map_public_ip_on_launch
}

resource "aws_subnet" "private_subnet2" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.private_subnet_2
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = var.private_subnet_map_public_ip_on_launch
}

resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.public_subnet1.id
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.public_subnet2.id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "natgw_route1" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = var.routetable_cidr
    nat_gateway_id = aws_nat_gateway.nat_gw1.id
  }
}

resource "aws_route_table" "natgw_route2" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = var.routetable_cidr
    nat_gateway_id = aws_nat_gateway.nat_gw2.id
  }
}

resource "aws_route_table_association" "private_subnet1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.natgw_route1.id
}

resource "aws_route_table_association" "private_subnet2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.natgw_route2.id
}

resource "aws_security_group" "eks_sg" {
  name        = "eks-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.eks_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.eks_sg.id
  cidr_ipv4         = var.cidr_ipv4
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.eks_sg.id
  cidr_ipv4         = var.cidr_ipv4
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "egress-sg" {
  security_group_id = aws_security_group.eks_sg.id
  cidr_ipv4         = var.cidr_ipv4
  ip_protocol       = "-1" 
}