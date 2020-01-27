provider "aws" {
  region  = "us-east-2"
  shared_credentials_file = "${pathexpand("~/.aws/credentials")}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
module "asg" {
  source                              = ".//../../modules/asg"
  name                                = "TEST-ASG"
  region                              = "us-east-2"
  environment                         = "TEST"

  security_groups = data.aws_security_groups.security.ids

  root_block_device  = [
    {
      volume_size = "8"
      volume_type = "standard"
    },
  ]

  # Auto scaling group
  vpc_zone_identifier       = data.aws_subnet_ids.public.ids #set after vpc install
  health_check_type         = "EC2"
  asg_min_size              = 0
  asg_max_size              = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  enable_autoscaling_schedule = true
}
data "aws_vpcs" "vpc_id" {
  tags = {
    Name = "TEST VPC"
  }
}
data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpcs.vpc_id.ids

  tags = {
    Tier = "Public"
  }
}
data "aws_security_groups" "security" {
  filter {
    name   = "TEST SECURITY"
    values = data.aws_vpcs.vpc_id.ids
  }
}
