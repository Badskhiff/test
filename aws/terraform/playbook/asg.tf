terraform {
  required_version = "> 0.12.13"
}
variable "aws_access_key" {
  default = ""
}
variable "aws_secret_key" {
  default = ""
}
provider "aws" {
  region  = "us-east-2"
  #shared_credentials_file = "${pathexpand("~/.aws/credentials")}"
   access_key = "${var.aws_access_key}"
   secret_key = "${var.aws_secret_key}"
}
module "iam" {
  source                          = "../modules/iam"
  name                            = "TEST-AIM"
  region                          = "us-east-2"
  environment                     = "TEST"

  aws_iam_role-principals         = [
    "ec2.amazonaws.com",
  ]
  aws_iam_policy-actions           = [
    "cloudwatch:GetMetricStatistics",
    "logs:DescribeLogStreams",
    "logs:GetLogEvents",
    "elasticache:Describe*",
    "rds:Describe*",
    "rds:ListTagsForResource",
    "ec2:DescribeAccountAttributes",
    "ec2:DescribeAvailabilityZones",
    "ec2:DescribeSecurityGroups",
    "ec2:DescribeVpcs",
    "ec2:Owner",
  ]
}
module "vpc" {
  source                              = "/../modules/vpc"
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

module "asg" {
  source                              = "../modules/asg"
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
module "alb" {
  source                  = "../modules/alb"
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
