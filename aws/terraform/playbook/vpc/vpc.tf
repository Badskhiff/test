variable "aws_access_key" {
  default = "AKIATTBUSM2QZYRIY3U4"
}
variable "aws_secret_key" {
  default = "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"
}
provider "aws" {
  region  = "us-east-2"
  #shared_credentials_file = "${pathexpand("~/.aws/credentials")}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
module "vpc" {
  source                              = ".//../../modules/vpc"
  name                                = "TEST-VPC"
  environment                         = "TEST"
  instance_tenancy                    = "dedicated"
  enable_dns_support                  = "true"
  enable_dns_hostnames                = "true"
  assign_generated_ipv6_cidr_block    = "false"
  enable_classiclink                  = "false"
  vpc_cidr                            = "172.30.0.0/16"
  private_subnet_cidrs                = ["172.30.60.0/20"]
  public_subnet_cidrs                 = ["172.30.80.0/20"]
  availability_zones                  = ["us-east-2a", "us-east-2b"]
  allowed_ports                       = ["80", "3306", "80", "443"]

  #Internet-GateWay
  enable_internet_gateway             = "true"
  #DHCP
  enable_dhcp_options                 = "false"
}