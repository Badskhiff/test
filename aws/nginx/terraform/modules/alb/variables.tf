variable "name" {
  description = "Name to be used on all resources as prefix"
  default     = "NGINX-ALB"
}

variable "environment" {
  description = "Environment for service"
  default     = "TEST"
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the ELB. Only valid if creating an ELB within a VPC"
  type        = "list"
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the ELB"
  type        = "list"
  default     = []
}

variable "lb_internal" {
  description = "If true, ALB will be an internal ALB"
  default     = false
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  default     = false
}

# Access logs

variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are application or network. The default value is application."
  default     = "application"
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle. Default: 60."
  default     = "60"
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack"
  default     = "ipv4"
}

variable "timeouts_create" {
  description = "Used for Creating LB. Default = 10mins"
  default     = "10m"
}

variable "timeouts_update" {
  description = "Used for LB modifications. Default = 10mins"
  default     = "10m"
}

variable "timeouts_delete" {
  description = "Used for LB destroying LB. Default = 10mins"
  default     = "10m"
}

variable "vpc_id" {
  description = "Set VPC ID for ?LB"
}

variable "target_type" {
  description = "The type of target that you must specify when registering targets with this target group. The possible values are instance (targets are specified by instance ID) or ip (targets are specified by IP address). The default is instance. Note that you can't specify targets for a target group using both instance IDs and IP addresses. If the target type is ip, specify IP addresses from the subnets of the virtual private cloud (VPC) for the target group, the RFC 1918 range (10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16), and the RFC 6598 range (100.64.0.0/10). You can't specify publicly routable IP addresses"
  default     = "instance"
}

variable "deregistration_delay" {
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 300 seconds."
  default     = "300"
}

variable "backend_port" {
  description = "The port the service on the EC2 instances listen on."
  default     = 80
}

variable "backend_protocol" {
  description = "The protocol the backend service speaks. Options: HTTP, HTTPS, TCP, SSL (secure tcp)."
  default     = "HTTP"
}

