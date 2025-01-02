terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      version = "5.80.0"
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-458"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

resource "aws_key_pair" "key" {
  public_key = file("${path.module}/ssh-keys/key-pair.pub")

  tags = {
    Name        = "${var.environment}-key-pair"
    environment = var.environment
  }
}

module "vpc" {
  source = "./vpc"

  environment = var.environment
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  vpc_azs = var.vpc_azs
  vpc_public_subnets = var.vpc_public_subnets
  vpc_private_subnets = var.vpc_private_subnets
}

module "frontend" {
  source = "./frontend"

  environment = var.environment
  vpc_id = module.vpc.vpc_id
  vpc_public_subnets = module.vpc.public_subnets
  frontend_ami = var.frontend_ami
  frontend_instance_type = var.frontend_instance_type
  frontend_autoscaling_max_size = var.frontend_autoscaling_max_size
  frontend_autoscaling_min_size = var.frontend_autoscaling_min_size
  frontend_autoscaling_desired_capacity = var.frontend_autoscaling_desired_capacity
  frontend_cidr_ip4_backend_target = var.frontend_cidr_ip4_backend_target

  public_subnets = var.vpc_public_subnets

  key_pair_name = aws_key_pair.key.key_name
}

module "backend" {
  source = "./backend"

  environment = var.environment
  vpc_id = module.vpc.vpc_id
  vpc_private_subnets = module.vpc.private_subnets
  backend_ami = var.backend_ami
  backend_instance_type = var.backend_instance_type
  backend_autoscaling_max_size = var.backend_autoscaling_max_size
  backend_autoscaling_min_size = var.backend_autoscaling_min_size
  backend_autoscaling_desired_capacity = var.backend_autoscaling_desired_capacity
  backend_cidr_ip4_backend_target = var.backend_cidr_ip4_backend_target

  key_pair_name = aws_key_pair.key.key_name
  private_subnets = var.vpc_private_subnets
  public_subnets = var.vpc_public_subnets

  mysql_username = var.mysql_username
  mysql_password = var.mysql_password
}

module "ansible_management" {
  source = "./ansible_management"

  environment = var.environment
  vpc_id = module.vpc.vpc_id
  private_subnet = module.vpc.public_subnets[1]
  instance_type = var.ansible_instance_type
  ami = var.ansible_ami
}