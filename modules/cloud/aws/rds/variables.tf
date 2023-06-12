variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "create_rds" {
  type    = bool
  default = false
}

variable "rds_identifier" {
  type    = string
  default = "postgres-rds-instance"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type        = string
  description = "Name of the database to create. *Note*: DBName must begin with a letter and contain only alphanumeric characters"
  default     = "ultimate-postgres-db"
}

variable "db_username" {
  type    = string
  default = "ultimate_postgres_user"
}

variable "backup_retention_period" {
  type    = number
  default = 0
}

variable "tags" {
  type = map(string)
  default = {
    Name = "ultimate-mlops-rds"
  }
}
