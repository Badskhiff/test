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
module "asg" {
  source                              = ".//../../modules/asg"
  name                                = "TEST-ASG"
  region                              = "us-east-2"
  environment                         = "TEST"

  security_groups = [
    module.vpc.security_group_id]

  root_block_device  = [
    {
      volume_size = "8"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  vpc_zone_identifier       = [
    module.vpc.vpc-publicsubnet-ids]
  health_check_type         = "EC2"
  asg_min_size              = 0
  asg_max_size              = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  enable_autoscaling_schedule = true
}

