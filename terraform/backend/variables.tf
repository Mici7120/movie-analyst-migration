variable "vpc_id" {
  description = "vpc id"
  type = string
}

variable "vpc_private_subnets" {
  description = "list of public_subnets"
  type = list
}

variable "environment" {
  description = "environment type"
  type = string
  default = "qa"
}

variable "backend_ami" {
  description = "image of the backend ec2 instance"
  type = string
}

variable "backend_instance_type" {
  description = "type of the ec2 instance"
  type = string
}

variable "backend_autoscaling_max_size" {
  description = "max size of the autoscaling group"
  type = number
}

variable "backend_autoscaling_min_size" {
  description = "min size of the autoscaling group"
  type = number
}

variable "backend_autoscaling_desired_capacity" {
  description = "desired capacity of the autoscaling group"
  type = number
}

variable "backend_cidr_ip4_backend_target" {
  description = "the cidr ipv4 address to connect to the backend"
  type = string
}

variable "mysql_username" {
  description = "mysql username"
  type = string
  default = "admin"
  sensitive = true
}

variable "mysql_password" {
  description = "mysql password"
  type = string
  sensitive = true
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

variable "private_subnets" {
  description = "list of private subnets of the frontend"
  type = list
}