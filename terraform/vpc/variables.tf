variable "environment" {
  description = "environment type"
  type = string
  default = "qa"
}

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