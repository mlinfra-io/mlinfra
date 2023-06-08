resource "aws_eip" "nat" {
  count = 3
}

data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "vpc_logs_bucket" {
  bucket = "vpc-flow-logs-bucket"
  tags   = local.tags
}

resource "aws_s3_bucket_acl" "vpc_logs_bucket_acl" {
  bucket = aws_s3_bucket.vpc_logs_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "flow_logs_lifecycle" {
  bucket = aws_s3_bucket.vpc_logs_bucket.id

  rule {
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


module "vpc_subnet_module" {
  source = "terraform-aws-modules/vpc/aws"
  # version = var.vpc_subnet_module.version
  version = "4.0.2"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  reuse_nat_ips       = true             # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids = aws_eip.nat.*.id # <= IPs specified here as input to the module
  enable_vpn_gateway  = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log                   = true
  flow_log_destination_type         = "s3"
  flow_log_destination_arn          = aws_s3_bucket.vpc_logs_bucket.arn
  flow_log_max_aggregation_interval = 600

  manage_default_network_acl = true

  tags = local.tags
}
