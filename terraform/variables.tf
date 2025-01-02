variable "environment" {
  description = "environment type"
  type = string
  default = "qa"
}

variable "aws_region" {
  description = "AWS Region"
  type = string
  default = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type = string
  sensitive = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type = string
  sensitive = true
}

# --- VPC VARIABLES ---
variable "vpc_name" {
  description = "VPC name"
  type = string
  default = "vpc-terraform"
}

variable "vpc_cidr" {
  description = "CIDR block"
  type = string
}

variable "vpc_azs" {
  description = "list of availability zones"
  type = list
}

variable "vpc_public_subnets" {
  description = "list of public_subnets"
  type = list
}

variable "vpc_private_subnets" {
  description = "list of private_subnets"
  type = list
}

# --- FRONTEND VARIABLES ---

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

# --- BACKEND VARIABLES ---

variable "backend_ami" {
  description = "image of the frontend ec2 instance"
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

# --- ansible management ---

variable "ansible_instance_type" {
  description = "instance type"
  type = string
}

variable "ansible_ami" {
  description = "ec2 image"
  type = string
}