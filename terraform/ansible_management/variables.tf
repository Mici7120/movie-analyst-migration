variable "environment" {
  description = "environment type"
  type = string
  default = "qa"
}

variable "vpc_id" {
  description = "vpc id"
  type = string
}

variable "private_subnet" {
  description = "private subnet"
  type = string
}

variable "instance_type" {
  description = "instance type"
  type = string
}

variable "ami" {
  description = "ec2 image"
  type = string
}