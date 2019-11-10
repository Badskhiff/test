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
}
module "alb" {
  source                  = ".//../../modules/alb"
  name                    = "App-Load-Balancer"
  region                  = "us-east-2"
  environment             = "TEST"

  load_balancer_type          = "application"
  security_groups             = [module.vpc.security_group_id, module.vpc.default_security_group_id]
  subnets                     = [module.vpc.vpc-privatesubnet-ids]
  vpc_id                      = module.vpc.vpc_id
  enable_deletion_protection  = false

  backend_protocol    = "HTTP"
  alb_protocols       = "HTTP"

  target_ids          = [module.ec2.instance_ids]

}