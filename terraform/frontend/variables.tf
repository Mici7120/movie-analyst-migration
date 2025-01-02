variable "vpc_id" {
  description = "vpc id"
  type = string
}

variable "vpc_public_subnets" {
  description = "list of public subnets id"
  type = list
}

variable "environment" {
  description = "environment type"
  type = string
  default = "qa"
}

variable "frontend_ami" {
  description = "image of the frontend ec2 instance"
  type = string
}

variable "frontend_instance_type" {
  description = "type of the ec2 instance"
  type = string
}

variable "frontend_autoscaling_max_size" {
  description = "max size of the autoscaling group"
  type = number
}

variable "frontend_autoscaling_min_size" {
  description = "min size of the autoscaling group"
  type = number
}

variable "frontend_autoscaling_desired_capacity" {
  description = "desired capacity of the autoscaling group"
  type = number
}

variable "frontend_cidr_ip4_backend_target" {
  description = "the cidr ipv4 address to connect to the backend"
  type = string
}

variable "key_pair_name" {
  description = "key pair name"
  type = string
  sensitive = true
}

variable "public_subnets" {
  description = "list of public subnets of the frontend"
  type = list
}
