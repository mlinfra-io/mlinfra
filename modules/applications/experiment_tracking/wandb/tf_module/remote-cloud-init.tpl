#!/bin/bash
sudo yum update -y
sudo yum -y install python3 python3-pip docker
python3 -m pip install --upgrade pip
sudo systemctl start docker
sudo groupadd docker
sudo usermod -aG docker $USER
python3 -m pip install --ignore-installed --upgrade pip
python3 -m pip install --ignore-installed wandb==${wandb_version}
nohup wandb server start --port ${ec2_application_port} --daemon \
    -e AWS_REGION=${aws_region} \
    -e MYSQL=mysql://${db_instance_username}:${db_instance_password}@${db_instance_endpoint}/${db_instance_name} \
    -e BUCKET=s3://${bucket_id} &
#    -e BUCKET_QUEUE= &
