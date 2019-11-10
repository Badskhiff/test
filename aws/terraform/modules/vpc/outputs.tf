output "instance_tenancy" {
  value = aws_vpc.test_vpc.instance_tenancy
}

output "vpc_id" {
  value = aws_vpc.test_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.test_vpc.cidr_block
}

output "default_network_acl_id" {
  value = aws_vpc.test_vpc.default_network_acl_id
}

output "security_group_id" {
  value = aws_security_group.test_security.id
}

output "default_security_group_id" {
  value = aws_vpc.test_vpc.default_security_group_id
}

output "public_route_table_ids" {
  value = [aws_route_table.public_route_tables.*.id]
}

output "private_route_table_ids" {
  value = [aws_route_table.private_route_tables.*.id]
}

output "vpc-publicsubnets" {
  value = aws_subnet.public_subnets.*.cidr_block
}

output "vpc-publicsubnet-id_0" {
  value = aws_subnet.public_subnets[0].id
}

output "vpc-publicsubnet-ids" {
  value = aws_subnet.public_subnets.*.id
}

output "vpc-privatesubnets" {
  value   = aws_subnet.private_subnets.*.cidr_block
}

output "vpc-privatesubnet-ids" {
  value = aws_subnet.private_subnets.*.id
}
# Internet Gateway
output "gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = element(concat(aws_internet_gateway.internet_gw.*.id, list("")), 0)
}
