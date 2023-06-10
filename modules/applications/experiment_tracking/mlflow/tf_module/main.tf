# TODO: the variables should be filled using the yaml
# files in mlflow directory

# module "mlflow" {
#   source               = "../../../../cloud/aws/ec2"
#   vpc_id               = var.vpc_id
#   default_vpc_sg       = var.default_vpc_sg
#   ec2_subnet_id        = var.ec2_subnet_id
#   ec2_instance_name    = "mlflow-server"
#   ec2_user_data        = <<-EOF
#                       #!/bin/bash
#                       sudo yum update -y
#                       sudo yum -y install python3 python3-pip
#                       python3 -m pip install --upgrade pip
#                       python3 -m pip install --ignore-installed mlflow==${var.mlflow_version}
#                       nohup mlflow server --host 0.0.0.0 --port ${var.ec2_application_port} &
#                       EOF
#   ec2_application_port = var.ec2_application_port
# }


# Hard coding the values for now...

module "mlflow" {
  source               = "../../../../cloud/aws/ec2"
  vpc_id               = var.vpc_id
  default_vpc_sg       = var.default_vpc_sg
  ec2_subnet_id        = var.subnet_id
  ec2_instance_name    = "mlflow-server"
  ec2_user_data        = <<-EOF
                      #!/bin/bash
                      sudo yum update -y
                      sudo yum -y install python3 python3-pip
                      python3 -m pip install --upgrade pip
                      python3 -m pip install --ignore-installed mlflow==${var.mlflow_version}
                      nohup mlflow server --host 0.0.0.0 --port ${var.ec2_application_port} &
                      EOF
  ec2_application_port = var.ec2_application_port
}
