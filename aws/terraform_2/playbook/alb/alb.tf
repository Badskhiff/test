provider "aws" {
  region  = "us-east-2"
  shared_credentials_file = file("/home/ubuntu/key/cred")
  #access_key = "${var.aws_access_key}"
  #secret_key = "${var.aws_secret_key}"
}
module "alb" {
  source                  = ".//../../modules/alb"
  name                    = "App-Load-Balancer"
  region                  = "us-east-2"
  environment             = "TEST"

  load_balancer_type          = "application"
  security_groups             = ["TEST SECURITY"]
  subnets                     = data.aws_subnet_ids.private.ids
  vpc_id                      = data.aws_vpcs.vpc_id.ids
  enable_deletion_protection  = false

  backend_protocol    = "HTTP"
  alb_protocols       = "HTTP"

}
data "aws_vpcs" "vpc_id" {
  tags = {
    Name = "TEST VPC"
  }
}
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpcs.vpc_id.ids

  tags = {
    Tier = "Private"
  }
}