####VPC Create block
#aws_vpc - function
#test_vpc - name (can use to call vpc_id  main_route_table_id)
#cidr_block  - vpc address
#instance_tenancy - «default»/«dedicated»/«host» instance type
#enable_dns_support - support dns to vpc
#enable_dns_hostname - indicates whether instances running in VPC will receive host names
#assign_generated_ipv6_cidr_block - generate ipv6
#enable_classiclink - ec2 link to vpc
#tags - to tag
resource "aws_vpc" "test_vpc" {
  cidr_block                          = cidrsubnet(var.vpc_cidr, 0, 0)
  instance_tenancy                    = var.instance_tenancy
  enable_dns_support                  = var.enable_dns_support
  enable_dns_hostnames                = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block    = var.assign_generated_ipv6_cidr_block
  enable_classiclink                  = var.enable_classiclink

  tags {
    Name            = "${lower(var.name)}-vpc-${lower(var.environment)}"
    Environment     = var.environment
    Orchestration   = var.orchestration
  }
}
####Security create block
#ingress/egress — Inbound / Outbound Connection for Specified Ports
#from_port - Inbound / Outbound connection for the specified port from the host
#to_port - Inbound / Outbound connection for the specified port on the host
#protocol - Specify the protocol that will be used for incoming / outgoing connections
resource "aws_security_group" "test_security" {
  name                = "${var.name}-test_security-${var.environment}"
  description         = "Security Group ${var.name}-test_security-${var.environment}"
  vpc_id              = aws_vpc.test_vpc.id
  tags {
    Name            = "${var.name}-test_security-${var.environment}"
    Environment     = var.environment
    Orchestration   = var.orchestration
  }
  lifecycle {
    create_before_destroy = true
  }
  # allow traffic for TCP 22 to host
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # allow traffic for TCP 22 from host
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on  = ["aws_vpc.test_vpc"]
}
####Create security rule
resource "aws_security_group_rule" "ingress_ports" {
  count               = length(var.allowed_ports)
  type                = "ingress"
  security_group_id   = aws_security_group.test_security.id
  from_port           = element(var.allowed_ports, count.index)
  to_port             = element(var.allowed_ports, count.index)
  protocol            = "tcp"
  cidr_blocks         = ["0.0.0.0/0"]
  depends_on          = ["aws_security_group.test_security"]
}
resource "aws_security_group_rule" "egress_ports" {
  count               = var.enable_all_egress_ports ? 0 : length(var.allowed_ports)
  type                = "egress"
  security_group_id   = aws_security_group.test_security.id
  from_port           = element(var.allowed_ports, count.index)
  to_port             = element(var.allowed_ports, count.index)
  protocol            = "tcp"
  cidr_blocks         = ["0.0.0.0/0"]
  depends_on          = ["aws_security_group.test_security"]
}
resource "aws_security_group_rule" "icmp-self" {
  security_group_id   = aws_security_group.test_security.id
  type                = "ingress"
  protocol            = "icmp"
  from_port           = -1
  to_port             = -1
  self                = true
  depends_on          = ["aws_security_group.test_security"]
}
resource "aws_security_group_rule" "default_egress" {
  count             = var.enable_all_egress_ports ? 1 : 0
  type              = "egress"
  security_group_id = aws_security_group.test_security.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  depends_on        = ["aws_security_group.test_security"]
}
####Create public subnet
#vpc_id - Identification number of the created VPC
#map_public_ip_on_launch - Specify true to indicate that instances running on the subnet must be assigned a public IP address. The default value is false
#availability_zone - Zone for subnet development
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  vpc_id                  = aws_vpc.test_vpc.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = element(var.availability_zones, 0)
  tags {
    Name            = "public_subnet-${element(var.availability_zones, count.index)}"
    Environment     = var.environment
    Orchestration   = var.orchestration
  }
  depends_on        = ["aws_vpc.test_vpc"]
}
####Create private subnet
resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnet_cidrs)
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  vpc_id                  = aws_vpc.test_vpc.id
  map_public_ip_on_launch = "false"
  availability_zone       = element(var.availability_zones, 0)
  tags {
    Name            = "private_subnet-${element(var.availability_zones, count.index)}"
    Environment     = var.environment
    Orchestration   = var.orchestration
  }
  depends_on        = ["aws_vpc.test_vpc"]
}
####Create internet gateway
resource "aws_internet_gateway" "internet_gw" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.test_vpc.id
  tags {
    Name            = "internet-gateway to ${var.name}-vpc-${var.environment}"
    Environment     = var.environment
    Orchestration   = var.orchestration
  }
  depends_on        = ["aws_vpc.test_vpc"]
}
resource "aws_route_table" "public_route_tables" {
  count            = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id           = aws_vpc.test_vpc.id
  propagating_vgws = [
    var.public_propagating_vgws]
  tags {
    Name            = "public_route_tables"
    Environment     = var.environment
    Orchestration   = var.orchestration
  }
  depends_on        = ["aws_vpc.test_vpc"]
}
resource "aws_route" "public_internet_gateway" {
  count                  = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public_route_tables.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id
  depends_on             = ["aws_internet_gateway.internet_gw", "aws_route_table.public_route_tables"]
}
####Create private route table
#---------------------------------------------------
resource "aws_route_table" "private_route_tables" {
  count               = length(var.availability_zones)
  vpc_id              = aws_vpc.test_vpc.id
  propagating_vgws    = [
    var.private_propagating_vgws]

  tags {
    Name            = "private_route_tables"
    Environment     = var.environment
    Orchestration   = var.orchestration
  }
  depends_on          = ["aws_vpc.test_vpc"]
}
####CREATE DHCP
resource "aws_vpc_dhcp_options" "vpc_dhcp_options" {
  count                = var.enable_dhcp_options ? 1 : 0
  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags {
    Name            = "dhcp"
    Environment     = var.environment
    Orchestration   = var.orchestration
  }
}
####Route Table Associations private

resource "aws_route_table_association" "private_route_table_associations" {
  count           = length(var.private_subnet_cidrs)
  subnet_id       = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id  = element(aws_route_table.private_route_tables.*.id, count.index)
  depends_on      = ["aws_route_table.private_route_tables", "aws_subnet.private_subnets"]
}
####Route Table Associations public
resource "aws_route_table_association" "public_route_table_associations" {
  count           = length(var.public_subnet_cidrs)
  subnet_id       = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id  = aws_route_table.public_route_tables.id
  depends_on      = ["aws_route_table.public_route_tables", "aws_subnet.public_subnets"]
}
#### DHCP Options
resource "aws_vpc_dhcp_options_association" "vpc_dhcp_options_association" {
  count           = var.enable_dhcp_options ? 1 : 0
  vpc_id          = aws_vpc.test_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.vpc_dhcp_options.id
  depends_on      = ["aws_vpc.test_vpc", "aws_vpc_dhcp_options.vpc_dhcp_options"]
}