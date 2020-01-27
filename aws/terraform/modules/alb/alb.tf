resource "aws_lb" "alb" {
  name                = var.name
  security_groups     = [var.security_groups]
  subnets             = [var.subnets]
  internal            = var.lb_internal

  enable_deletion_protection  = var.enable_deletion_protection
  load_balancer_type          = var.load_balancer_type
  idle_timeout                = var.idle_timeout
  ip_address_type             = var.ip_address_type

  timeouts {
    create  = var.timeouts_create
    update  = var.timeouts_update
    delete  = var.timeouts_delete
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name            = var.name
    Environment     = var.environment
  }
}
resource "aws_lb_target_group" "alb_target_group" {
  name                 = var.name
  port                 = var.backend_port
  protocol             = upper(var.backend_protocol)
  vpc_id               = var.vpc_id
  target_type          = var.target_type
  deregistration_delay = var.deregistration_delay

  tags {
    Name            = var.name
    Environment     = var.environment
  }
}
resource "aws_lb_listener" "app_http" {
  load_balancer_arn   = aws_lb.alb.arn
  port                = "80"
  protocol            = "HTTP"

  default_action {
    target_group_arn    = aws_lb_target_group.alb_target_group.arn
    type                = "forward"
  }

  depends_on = ["aws_lb.alb","aws_lb_target_group.alb_target_group"]
}
resource "aws_lb_target_group_attachment" "alb_target_group_attachment" {
  count               = length(data.aws_instances.asg_instance.ids)
  target_group_arn    = aws_lb_target_group.alb_target_group.arn
  target_id           = data.aws_instances.asg_instance.ids[count.index]
  port                = var.backend_port

  depends_on = ["aws_lb.alb","aws_lb_target_group.alb_target_group"]
}
data "aws_instances" "asg_instance" {
  filter {
    name   = "name"
    values = ["TEST-ASG*"]
  }
}