variable "vpc_id" {
  type = string
}

variable "default_vpc_sg" {
  type = string
  # value usually comes from vpc module as
  # module.vpc_subnet_module.default_security_group_id
}

variable "vpc_cidr_block" {
  type = string
}

variable "ec2_subnet_id" {
  type = string
}

variable "ec2_instance_name" {
  type = string
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_spot_instance" {
  type    = bool
  default = true
}

variable "iam_instance_profile" {
  type    = string
  default = null
}

variable "ec2_user_data" {
  type    = string
  default = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum -y install python3 python3-pip
                python3 -m pip install --upgrade pip
                EOF
}

variable "tags" {
  type = map(string)
  default = {
    Name = "ultimate-mlops-instance"
  }
}

variable "ec2_application_port" {
  type = number
}

variable "enable_rds_ingress_rule" {
  type    = bool
  default = false
}

variable "rds_type" {
  type    = string
  default = "postgres"
}

variable "additional_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = list(string)
  }))
  default = null
}
