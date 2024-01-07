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

variable "rds_engine" {
  type    = string
  default = "postgres"
}

variable "rds_engine_version" {
  type    = string
  default = "14"
}

variable "rds_family" {
  type    = string
  default = "postgres14"
}

variable "rds_major_engine_version" {
  type    = string
  default = "14"
}

variable "rds_instance_class" {
  type    = string
  default = "db.t4g.medium"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type        = string
  description = "Name of the database to create. *Note*: DBName must begin with a letter and contain only alphanumeric characters"
  default     = "ultimatepostgresdb"
}

variable "db_username" {
  type    = string
  default = "ultimate_postgres_user"
}

variable "rds_port" {
  type    = number
  default = 5432
}

variable "skip_final_snapshot" {
  type        = bool
  description = "If set to true, no final snapshot of the RDS instance will be created"
  default     = false
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
