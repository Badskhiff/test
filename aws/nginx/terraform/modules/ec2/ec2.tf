resource "aws_key_pair" "key_pair" {
  key_name = "test-very-secret-key"
  public_key = "ssh-rsa very-big-rsa badskhiff@gmail.com"
}

resource "aws_instance" "nginx" {
  count                       = length(local.uniq_answers_filtered) + 1

  ami                         = data.aws_ami.nginx_ami.id
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.key_pair.id
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [
    var.vpc_security_group_ids]
  monitoring                  = var.monitoring
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.enable_associate_public_ip_address
  private_ip                  = var.private_ip

  source_dest_check                    = var.source_dest_check
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  placement_group                      = var.placement_group
  tenancy                              = var.tenancy

  ebs_optimized          = var.ebs_optimized
  volume_tags            = var.volume_tags
  root_block_device {
    volume_size = var.disk_size
    #    volume_type = "gp2"
  }
  ebs_block_device       = var.ebs_block_device
  ephemeral_block_device = var.ephemeral_block_device

  lifecycle {
    create_before_destroy = true
    ignore_changes = ["private_ip", "vpc_security_group_ids", "root_block_device"]
  }

  tags {
    Name            = "${lower(var.name)}-${count.index+1}"
  }

  depends_on = ["aws_key_pair.key_pair"]
}

data "aws_ami" "nginx_ami" {
  most_recent = true
  owners = ["self"]
  filter {
    name   = "name"
    values = ["nginx-*"]
  }
}

#Well, a very large collective farm

data "external" "az_type" {
  count = length(var.ec2_instance_type)

  program = ["bash", "${path.module}/check_instance_availability.sh"]

  query = {
    type    = var.ec2_instance_type
    region  = var.region
    profile = "${var.aws_profile}"
  }
}

locals {
  uniq_answers = distinct(data.external.az_type.*.result)

  uniq_answers_filtered = [
  for a in local.uniq_answers :
  a if length(a) != 0
  ]

}
