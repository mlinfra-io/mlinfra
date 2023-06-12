variable "name" {
  type    = string
  default = "ultimate-mlops-stack-vpc"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type = list(string)
  default = [
    "10.0.0.0/20",
    "10.0.16.0/20",
    "10.0.32.0/20"
  ]
}

variable "private_subnet_cidr" {
  type = list(string)
  default = [
    "10.0.128.0/20",
    "10.0.144.0/20",
    "10.0.160.0/20"
  ]
}

variable "create_database_subnets" {
  type    = bool
  default = false
}

variable "database_subnets" {
  type = list(string)
  default = [
    "10.0.64.0/20",
    "10.0.80.0/20",
    "10.0.96.0/20"
  ]
}

variable "one_nat_gateway_per_az" {
  type    = bool
  default = false
}

variable "enable_flow_log" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
