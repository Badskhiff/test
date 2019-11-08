#---------------------------------------------------
# Create VPC
#---------------------------------------------------
resource "aws_vpc" "aws_vpc" {
  cidr_block                          = "${var.vpc_cidr}"
  instance_tenancy                    = "default"
  enable_dns_support                  = "true"
  enable_dns_hostnames                = "true"
  assign_generated_ipv6_cidr_block    = "false"
  enable_classiclink                  = "false"
  tags {
    Name            = "my-vpc"
  }
}

#---------------------------------------------------
# Add AWS subnet (private)
#---------------------------------------------------
resource "aws_subnet" "aws_subnet_private" {
  cidr_block              = "172.31.64.0/20"
  vpc_id                  = "${aws_vpc.aws_vpc.id}"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"
  tags {
    Name            = "aws_subnet_private"
  }
}

#---------------------------------------------------
# Add AWS subnet (public)
#---------------------------------------------------
resource "aws_subnet" "aws_subnet_public" {
  cidr_block              = "172.31.80.0/20"
  vpc_id                  = "${aws_vpc.aws_vpc.id}"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"
  tags {
    Name            = "aws_subnet_public"
  }
}

#---------------------------------------------------
# Add AWS internet gateway
#---------------------------------------------------
resource "aws_internet_gateway" "aws_internet_gateway" {
  vpc_id = "${aws_vpc.aws_vpc.id}"
  tags {
    Name            = "internet-gateway"
  }
}

resource "aws_route_table" "aws_route_table" {
  vpc_id = "${aws_vpc.aws_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.aws_internet_gateway.id}"
  }
  tags {
    Name            = "aws_internet_gateway-default"
    Environment     = "${var.environment}"
    Orchestration   = "${var.orchestration}"

  }
}
resource "aws_route_table_association" "aws_route_table_association" {
  subnet_id       = "${aws_subnet.aws_subnet_private.id}"
  route_table_id  = "${aws_route_table.aws_route_table.id}"
}

or

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.aws_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.aws_internet_gateway.id}"
}

