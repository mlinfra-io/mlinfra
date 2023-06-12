locals {
  db_subnets = var.create_database_subnets ? var.database_subnets : []
}

module "vpc_module" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  depends_on = [aws_s3_bucket.vpc_logs_bucket]

  name = var.name
  cidr = var.cidr_block

  azs              = local.azs
  private_subnets  = var.private_subnet_cidr
  public_subnets   = var.public_subnet_cidr
  database_subnets = local.db_subnets

  create_database_subnet_group = var.create_database_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log                   = true
  flow_log_destination_type         = "s3"
  flow_log_destination_arn          = aws_s3_bucket.vpc_logs_bucket.arn
  flow_log_max_aggregation_interval = 600

  manage_default_network_acl = true

  tags = local.tags
}
