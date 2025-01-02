module  "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = var.vpc_name

  cidr = var.vpc_cidr
  azs = var.vpc_azs
  public_subnets = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets

  # allocate the nat_gateway in the first public_subnet
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    terraform = true
    environment = var.environment
  }
}