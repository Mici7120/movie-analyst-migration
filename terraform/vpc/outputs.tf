output "vpc_id" {
  description = "vpc id"
  value = module.vpc.vpc_id
}

output "public_subnets" {
  description = "public_subnets"
  value = module.vpc.public_subnets
}

output "private_subnets" {
  description = "private_subnets"
  value = module.vpc.private_subnets
}