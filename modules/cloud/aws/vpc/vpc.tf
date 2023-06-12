locals {
  db_subnets = var.create_database_subnets ? var.database_subnets : []
}

resource "aws_s3_bucket" "vpc_logs_bucket" {
  count = var.enable_flow_log ? 1 : 0

  bucket = "ultimate-mlops-vpc-flowlogs-bucket"
  tags   = local.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "flow_logs_lifecycle" {
  count = var.enable_flow_log ? 1 : 0

  bucket = aws_s3_bucket.vpc_logs_bucket[0].id

  rule {
    filter {
      prefix = "AWSLogs/"
    }

    id     = "MoveLogsToGlacier"
    status = "Enabled"

    transition {
      days          = 10
      storage_class = "GLACIER"
    }

    expiration {
      days = 60
    }
  }
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

  enable_flow_log                   = var.enable_flow_log
  flow_log_destination_type         = "s3"
  flow_log_destination_arn          = aws_s3_bucket.vpc_logs_bucket[0].arn
  flow_log_max_aggregation_interval = 600

  manage_default_network_acl = true

  tags = local.tags
}
