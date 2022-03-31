variable "vpc_id" {}
variable "aws_region" {}
variable "servicename" {}
variable "hostname" {}
variable "ClusterName" {}
variable "maincontainer" {}
variable "profile" {}
variable "listener_arn" {}
variable "service_tags" {}

provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

resource "aws_lb_target_group" "creation-tg" {
  name     = var.servicename
  deregistration_delay = 30
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener_rule" "feed" {
  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.creation-tg.arn
  }

  condition {
    host_header {
      values = [var.hostname]
    }
  }
}

data "aws_ecs_cluster" "CLUSTER" {
  cluster_name = var.ClusterName
}

module "service" {
  source = "git::https://github.com/cloudposse/terraform-aws-ecs-alb-service-task.git?ref=0.42.3"

  name                      = var.servicename
  environment               = ""
  container_definition_json = file("task-definitions/${var.servicename}-td.json")
  container_port            = 80
  desired_count             = 1
  ecs_cluster_arn           = data.aws_ecs_cluster.CLUSTER.arn
  ecs_load_balancers = [
    {
      container_name   = var.maincontainer
      container_port   = 5555
      elb_name         = ""
      target_group_arn = aws_lb_target_group.creation-tg.arn
    }
  ]
  volumes                = null
  launch_type            = "EC2"
  network_mode           = "bridge"
  use_alb_security_group = false
  subnet_ids             = null
  tags                   = var.service_tags
  task_cpu               = null
  task_memory            = null
  vpc_id                 = var.vpc_id
  ignore_changes_task_definition = false
}