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

variable "lakefs_data_bucket_name" {
  type    = string
  default = "ultimate-lakefs-data-bucket"
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
  default = false
}

variable "database_type" {
  type    = string
  default = null

  validation {
    condition     = (var.database_type == "dynamodb" || var.database_type == "postgres" || var.database_type == null)
    error_message = "database_type must be either 'dynamodb' or 'postgres'"
  }
}

variable "dynamodb_table_name" {
  type    = string
  default = "kvstore"
}

variable "tags" {
  type = map(string)
  default = {
    Name = "ultimate-mlops-instance"
  }
}
