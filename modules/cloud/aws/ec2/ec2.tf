data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_security_group" "mlflow_sg" {
  name        = "${var.ec2_instance_name}-security-group"
  description = "Security group for ${var.ec2_instance_name}"

  vpc_id = var.vpc_id

  # Allows SSH access from AWS Console for trouble shooting
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ec2_application_port
    to_port     = var.ec2_application_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allows instance to access the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.0.0"

  subnet_id              = var.ec2_subnet_id
  vpc_security_group_ids = [var.default_vpc_sg, aws_security_group.mlflow_sg.id]

  name          = var.ec2_instance_name
  instance_type = var.ec2_instance_type

  ami = data.aws_ami.amazon_linux_2023.id

  create_spot_instance        = true
  associate_public_ip_address = true

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 10
    }
  ]

  user_data = var.ec2_user_data

  tags = var.tags
}
