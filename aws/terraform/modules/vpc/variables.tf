#Global variables
variable "name" {
  description = "Name to be used on all resources as prefix"
  default     = "TEST-VPC"
}

variable "instance_tenancy" {
  description = "instance tenancy"
  default     = "default"
}

variable "enable_dns_support" {
  description = "Enabling dns support"
  default     = "true"
}

variable "enable_dns_hostnames" {
  description = "Enabling dns hostnames"
  default     = "true"
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Generation IPv6"
  default     = "false"
}

variable "enable_classiclink" {
  description = "Enabling classiclink"
  default     = "false"
}

variable "environment" {
  description = "Environment for service"
  default     = "STAGE"
}

variable "orchestration" {
  description = "Type of orchestration"
  default     = "Terraform"
}
#Custom variables
variable "allowed_ports" {
  description = "Allowed ports from/to host"
  type        = "list"
}

variable "enable_all_egress_ports" {
  description = "Allows all ports from host"
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
}

variable "public_subnet_cidrs" {
  description = "CIDR for the Public Subnet"
  type        = "list"
  default     = []
}

variable "private_subnet_cidrs" {
  description = "CIDR for the Private Subnet"
  type        = "list"
  default     = []
}

variable "availability_zones" {
  description = "A list of Availability zones in the region"
  type        = "list"
  default     = []
}

variable "enable_internet_gateway" {
  description = "Allow Internet GateWay to/from public network"
  default     = "false"
}

variable "private_propagating_vgws" {
  description = "A list of VGWs the private route table should propagate."
  type        = "list"
  default     = []
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate."
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "should be false if you do not want to auto-assign public IP on launch"
  default     = "true"
}

variable "enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set"
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided"
  type        = "list"
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set"
  type        = "list"
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set"
  type        = "list"
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set"
  default     = ""
}
