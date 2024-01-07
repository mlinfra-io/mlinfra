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

variable "dagster_artifacts_bucket_name" {
  type    = string
  default = "ultimate-dagster-artifacts-storage-bucket"
}

variable "app_versions" {
  type = object({
    dagster = string
    dagit   = string
  })
  default = {
    dagster = "1.3.12"
    dagit   = "1.3.12"
  }
}

variable "vs_code_version" {
  type    = string
  default = "4.14.1"
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

variable "tags" {
  type = map(string)
  default = {
    Name = "ultimate-mlops-instance"
  }
}
