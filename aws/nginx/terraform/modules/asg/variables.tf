variable "name" {
  description = "Name to be used on all resources as prefix"
  default     = "TEST-ASG"
}

variable "region" {
  description = "The region where to deploy this code (e.g. us-east-1)."
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment for service"
  default     = "TEST"
}

variable "create_lc" {
  description = "Whether to create launch configuration"
  default     = true
}

variable "create_asg" {
  description = "Whether to create autoscaling group"
  default     = true
}

# Launch configuration
variable "launch_configuration" {
  description = "The name of the launch configuration to use (if it is created outside of this module)"
  default     = ""
}

variable "ec2_instance_type" {
  description = "Type of instance t2.micro, m1.xlarge, c1.medium etc"
  default     = "t2.micro"
}

#variable "iam_instance_profile" {
#  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
#  default     = ""
#}

variable "key_path" {
  description = "Key path to your RSA|DSA key"
  default     = "/home/ubuntu/key/terraform_ec2_key.pub"
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the launch configuration"
  type        = "list"
}

variable "enable_associate_public_ip_address" {
  description = "Enabling associate public ip address (Associate a public ip address with an instance in a VPC)"
  default     = false
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  default     = []
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  default     = []
}

variable "ephemeral_block_device" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance"
  default     = []
}

variable "placement_tenancy" {
  description = "The tenancy of the instance. Valid values are 'default' or 'dedicated'"
  default     = "default"
}

variable "availability_zones" {
  description = "Availability zones for AWS ASG"
  type        = "map"
  default     = {
    us-east-1      = "us-east-1b,us-east-1c,us-east-1d,us-east-1e"
    us-east-2      = "us-east-2a,eu-east-2b,eu-east-2c"
  }
}

variable "ami" {
  description = "regions"
  type        = "map"
  default     = {
    us-east-2 = "ami-09e7cafd5240be236"
  }
}
variable "enable_create_before_destroy" {
  description = "Create before destroy"
  default     = "true"
}

# Autoscaling group
variable "asg_max_size" {
  description = "Max size of instances to making autoscaling"
  default     = "1"
}

variable "asg_size_scale" {
  description = "Size of instances to making autoscaling(up/down)"
  default     = "1"
}

variable "asg_min_size" {
  description = "Min size of instances to making autoscaling"
  default     = "1"
}

variable "desired_capacity" {
  description = "Desired numbers of servers in ASG"
  default     = 1
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in"
  type        = "list"
}

variable "default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  default     = 300
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health."
  default     = 300
}

variable "health_check_type" {
  description = "Controls how health checking is done. Need to choose 'EC2' or 'ELB'"
  default     = "EC2"
}

variable "force_delete" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate."
  default     = "true"
}

variable "load_balancers" {
  description = "A list of elastic load balancer names to add to the autoscaling group names"
  default     = []
}

variable "target_group_arns" {
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing"
  default     = []
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default"
  type        = "list"
  default     = ["Default"]
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  default     = "10m"
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events."
  default     = false
}

variable "enable_autoscaling_lifecycle_hook" {
  description = "Enable autoscaling lifecycle hook"
  default     = false
}

variable "autoscaling_lifecycle_hook_lifecycle_transition" {
  description = "(Required) The instance state to which you want to attach the lifecycle hook."
  default     = "autoscaling:EC2_INSTANCE_LAUNCHING"
}
