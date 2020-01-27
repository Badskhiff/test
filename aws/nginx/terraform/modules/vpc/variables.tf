#Global variables
variable "name" {
  description = "Name to be used on all resources as prefix"
  default     = "NGINX-VPC"
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

variable "map_public_ip_on_launch" {
  description = "should be false if you do not want to auto-assign public IP on launch"
  default     = "true"
}
