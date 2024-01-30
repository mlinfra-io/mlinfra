output "vpc_id" {
  value = module.vpc_module.vpc_id
}

output "public_subnets_ids" {
  value = module.vpc_module.public_subnets
}

output "private_subnets_ids" {
  value = module.vpc_module.private_subnets
}

output "default_vpc_sg" {
  value = module.vpc_module.default_security_group_id
}

output "vpc_cidr_block" {
  value = module.vpc_module.vpc_cidr_block
}

output "database_subnet_group" {
  value = module.vpc_module.database_subnet_group
}
