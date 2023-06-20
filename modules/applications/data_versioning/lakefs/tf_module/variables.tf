variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "default_vpc_sg" {
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

variable "rds_instance_class" {
  type    = string
  default = "db.t4g.medium"
}

variable "lakefs_version" {
  type    = string
  default = "0.104.0"
}

variable "ec2_application_port" {
  type    = number
  default = 80
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_spot_instance" {
  type    = bool
  default = true
}

variable "remote_tracking" {
  type    = bool
  default = true
}

variable "database_type" {
  type    = string
  default = "postgres"
}

variable "tags" {
  type = map(string)
  default = {
    Name = "ultimate-mlops-instance"
  }
}
