data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = merge({
    Terraform   = "true"
    Environment = "dev"
  }, var.tags)
}
