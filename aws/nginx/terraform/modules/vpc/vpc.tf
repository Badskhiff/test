resource "aws_vpc" "nginx_vpc" {
  cidr_block                          = cidrsubnet(var.vpc_cidr, 0, 0)
  instance_tenancy                    = var.instance_tenancy
  enable_dns_support                  = var.enable_dns_support
  enable_dns_hostnames                = var.enable_dns_hostnames
  tags = {
    Name = var.name
  }
}
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  vpc_id                  = aws_vpc.nginx_vpc.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = element(var.availability_zones, 0)
  depends_on              = ["aws_vpc.nginx_vpc"]
  tags = {
    Name                  = "Public subnet"
  }
}
resource "aws_security_group" "security" {
  name                = "TEST SECURITY"
  description         = "TEST SECURITY"
  vpc_id              = aws_vpc.nginx_vpc.id
  #to host
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #from host
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on  = ["aws_vpc.nginx_vpc"]
}
resource "aws_security_group_rule" "ingress_ports" {
  count               = length(var.allowed_ports)
  type                = "ingress"
  security_group_id   = aws_security_group.security.id
  from_port           = element(var.allowed_ports, count.index)
  to_port             = element(var.allowed_ports, count.index)
  protocol            = "tcp"
  cidr_blocks         = ["0.0.0.0/0"]
  depends_on          = ["aws_security_group.security"]
}
resource "aws_security_group_rule" "egress_ports" {
  count               = var.enable_all_egress_ports ? 0 : length(var.allowed_ports)
  type                = "egress"
  security_group_id   = aws_security_group.security.id
  from_port           = element(var.allowed_ports, count.index)
  to_port             = element(var.allowed_ports, count.index)
  protocol            = "tcp"
  cidr_blocks         = ["0.0.0.0/0"]
  depends_on          = ["aws_security_group.security"]
}
resource "aws_internet_gateway" "internet_gw" {
  count             = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id            = aws_vpc.nginx_vpc.id
  depends_on        = ["aws_vpc.nginx_vpc"]
}
resource "aws_route_table" "public_route_tables" {
  count            = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id           = aws_vpc.nginx_vpc.id
  depends_on       = ["aws_vpc.nginx_vpc"]
}
resource "aws_route" "public_internet_gateway" {
  count                  = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  route_table_id         = element(aws_route_table.public_route_tables.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_internet_gateway.internet_gw.*.id, count.index)
  depends_on             = ["aws_internet_gateway.internet_gw", "aws_route_table.public_route_tables"]
}

resource "aws_route_table_association" "public_route_table_associations" {
  count           = length(var.public_subnet_cidrs)
  subnet_id       = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id  = element(aws_route_table.public_route_tables.*.id, count.index)
  depends_on      = ["aws_route_table.public_route_tables", "aws_subnet.public_subnets"]
}
