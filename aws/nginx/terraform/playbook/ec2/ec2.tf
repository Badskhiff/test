provider "aws" {
  region  = "us-east-2"
  shared_credentials_file = "${pathexpand("~/.aws/credentials")}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
module "vpc" {
  source = ".//../../modules/vpc"
}
module "ec2" {
  source                              = ".//../../modules/ec2"
  name                                = "NGINX-Machine"
  region                              = "us-east-2"
  environment                         = "TEST"
  ec2_instance_type                   = "t2.micro"
  enable_associate_public_ip_address  = "true"
  disk_size                           = "8"
  tenancy                             = module.vpc.instance_tenancy
  subnet_id                           = data.aws_subnet_ids.public.ids
  vpc_security_group_ids              = ["TEST SECURITY"]
  monitoring                          = "true"
}

data "aws_vpcs" "vpc_id" {
  tags = {
    Name = "NGINX-VPC"
  }
}
data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpcs.vpc_id.ids
  tags = {
    Tier = "Public"
  }
}
