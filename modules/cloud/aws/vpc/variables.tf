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

variable "one_nat_gateway_per_az" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
