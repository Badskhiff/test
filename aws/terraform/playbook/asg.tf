
terraform {
  required_version = "> 0.9.0"
}
provider "aws" {
  region  = "us-east-1"
  profile = "default"
  # Make it faster by skipping something
  #skip_get_ec2_platforms      = true
  #skip_metadata_api_check     = true
  #skip_region_validation      = true
  #skip_credentials_validation = true
  #skip_requesting_account_id  = true
}
module "iam" {
  source                          = "../modules/iam"
  name                            = "TEST-AIM"
  region                          = "us-east-1"
  environment                     = "PROD"

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
  # VPC
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
  region                              = "us-east-1"
  environment                         = "PROD"

  security_groups = ["${module.vpc.security_group_id}"]

  root_block_device  = [
    {
      volume_size = "8"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  #asg_name                  = "example-asg"
  vpc_zone_identifier       = ["${module.vpc.vpc-publicsubnet-ids}"]
  health_check_type         = "EC2"
  asg_min_size              = 0
  asg_max_size              = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  load_balancers            = ["${module.elb.elb_name}"]

  #
  enable_autoscaling_schedule = true
}
module "alb" {
  source                  = "../modules/alb"
  name                    = "App-Load-Balancer"
  region                  = "us-east-1"
  environment             = "PROD"

  load_balancer_type          = "application"
  security_groups             = ["${module.vpc.security_group_id}", "${module.vpc.default_security_group_id}"]
  subnets                     = ["${module.vpc.vpc-privatesubnet-ids}"]
  vpc_id                      = "${module.vpc.vpc_id}"
  enable_deletion_protection  = false

  backend_protocol    = "HTTP"
  alb_protocols       = "HTTP"

  target_ids          = ["${module.ec2.instance_ids}"]

  #access_logs = [
  #    {
  #        enabled         = true
  #        bucket          = "${module.s3.bucket_name}"
  #        prefix          = "log"
  #    },
  #]

}
