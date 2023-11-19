resource "aws_security_group" "ec2_security_group" {
  name        = "${var.ec2_instance_name}-security-group"
  description = "Security group for ${var.ec2_instance_name}"

  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  # Allows instance to access the internet
  dynamic "egress" {
    for_each = local.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0.0"

  subnet_id              = var.ec2_subnet_id
  vpc_security_group_ids = [var.default_vpc_sg, resource.aws_security_group.ec2_security_group.id]

  name          = var.ec2_instance_name
  instance_type = var.ec2_instance_type

  ami = data.aws_ami.amazon_linux_2023.id

  create_spot_instance        = var.ec2_spot_instance
  associate_public_ip_address = true

  iam_instance_profile = var.iam_instance_profile

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
