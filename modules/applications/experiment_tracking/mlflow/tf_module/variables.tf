variable "vpc_id" {
  type = string
}

variable "default_vpc_sg" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_cidr_block" {
  type    = string
  default = null
}

variable "db_subnet_group_name" {
  type    = string
  default = null
}

variable "mlflow_version" {
  type    = string
  default = "2.4.0"
}

variable "ec2_application_port" {
  type    = number
  default = 80
}

variable "remote_tracking" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
  default = {
    Name = "ultimate-mlops-instance"
  }
}
