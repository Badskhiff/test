provider "aws" {
  region  = "us-east-2"
  shared_credentials_file = "${pathexpand("~/.aws/credentials")}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
module "vpc" {
  source                              = ".//../../modules/vpc"
  name                                = "TEST-VPC"
  instance_tenancy                    = "dedicated"
  enable_dns_support                  = "true"
  enable_dns_hostnames                = "true"
  vpc_cidr                            = "172.30.0.0/16"
  private_subnet_cidrs                = ["172.30.60.0/20"]
  public_subnet_cidrs                 = ["172.30.80.0/20"]
  availability_zones                  = ["us-east-2a", "us-east-2b"]
  allowed_ports                       = ["80", "443"]
}
