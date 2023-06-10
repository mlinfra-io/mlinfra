variable "vpc_id" {
  type = string
}

variable "default_vpc_sg" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "mlflow_version" {
  type    = string
  default = "2.4.0"
}

variable "tags" {
  type = map(string)
  default = {
    Name = "ultimate-mlops-instance"
  }
}

variable "ec2_application_port" {
  type    = number
  default = 80
}
