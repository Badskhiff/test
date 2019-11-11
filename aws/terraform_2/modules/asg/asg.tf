resource "aws_key_pair" "key_pair" {
  key_name = "aws_test"
  public_key = file(var.key_path)
}
resource "aws_launch_configuration" "lc" {
  count                       = var.create_lc
  name_prefix                 = "${var.name}-lc-"
  image_id                    = data.aws_ami.app_ami.id
  instance_type               = var.ec2_instance_type
  #security_groups             = [var.security_groups]
  #iam_instance_profile        = var.iam_instance_profile

  key_name                    = aws_key_pair.key_pair.id
  associate_public_ip_address = var.enable_associate_public_ip_address

  placement_tenancy           = var.placement_tenancy

  ebs_optimized               = var.ebs_optimized
  ebs_block_device            = var.ebs_block_device
  ephemeral_block_device      = var.ephemeral_block_device
  root_block_device           = var.root_block_device

  lifecycle {
    create_before_destroy = "true"
  }
  depends_on = ["aws_key_pair.key_pair"]
}
resource "aws_autoscaling_group" "asg" {
  count                       = var.create_asg
  launch_configuration        = var.create_lc ? element(aws_launch_configuration.lc.*.name, 0) : var.launch_configuration
  name_prefix                 = "${var.name}-asg-"
  max_size                    = var.asg_max_size
  min_size                    = var.asg_min_size
  vpc_zone_identifier         = [var.vpc_zone_identifier]
  desired_capacity            = var.desired_capacity

  health_check_grace_period   = var.health_check_grace_period
  health_check_type           = var.health_check_type
  load_balancers              = [var.load_balancers]
  target_group_arns           = [var.target_group_arns]
  default_cooldown            = var.default_cooldown
  force_delete                = var.force_delete
  termination_policies        = var.termination_policies
  wait_for_capacity_timeout   = var.wait_for_capacity_timeout
  protect_from_scale_in       = var.protect_from_scale_in

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
  ]

  depends_on  = ["aws_launch_configuration.lc"]
}
resource "aws_autoscaling_lifecycle_hook" "autoscaling_lifecycle_hook" {
  count                   = "${var.enable_autoscaling_lifecycle_hook && !var.enable_asg_azs ? 1 : 0 }"

  name                    = "${lower(var.name)}-asg-lifecycle-hook-${lower(var.environment)}"
  autoscaling_group_name  = "${length(var.autoscaling_group_name) > 0 ? "${var.autoscaling_group_name}" : "${aws_autoscaling_group.asg.name}" }"

  default_result          = "${var.autoscaling_lifecycle_hook_default_result}"
  heartbeat_timeout       = "${var.autoscaling_lifecycle_hook_heartbeat_timeout}"
  lifecycle_transition    = "${var.autoscaling_lifecycle_hook_lifecycle_transition}"

  notification_metadata   = "${var.autoscaling_lifecycle_hook_notification_metadata}"

  notification_target_arn = "${var.autoscaling_lifecycle_hook_notification_target_arn}"
  role_arn                = "${var.autoscaling_lifecycle_hook_role_arn}"

  lifecycle {
    create_before_destroy   = true
    ignore_changes          = []
  }

  depends_on = ["aws_autoscaling_group.asg"]
}
data "aws_ami" "app_ami" {
  most_recent = true
  owners = ["self"]
  filter {
    name   = "name"
    values = ["aws_test*"]
  }
}