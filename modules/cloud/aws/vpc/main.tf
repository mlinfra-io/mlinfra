resource "aws_eip" "nat" {
  count = 3
  vpc   = true
}

data "aws_availability_zones" "available" {}

module "vpc_subnet_module" {
  source = "terraform-aws-modules/vpc/aws"
  # version = var.vpc_subnet_module.version
  version = "4.0.2"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway  = true
  single_nat_gateway  = false
  reuse_nat_ips       = true             # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids = aws_eip.nat.*.id # <= IPs specified here as input to the module
  enable_vpn_gateway  = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
