output "vpc_id" {
  value = module.vpc_module.vpc_id
}

output "subnet_id" {
  value = module.vpc_module.public_subnets
}

output "default_vpc_sg" {
  value = module.vpc_module.default_security_group_id
}
