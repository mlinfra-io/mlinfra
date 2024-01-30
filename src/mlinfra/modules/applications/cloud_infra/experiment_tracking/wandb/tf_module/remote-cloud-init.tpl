#!/bin/bash
sudo yum update -y
sudo yum -y install python3 python3-pip docker
python3 -m pip install --upgrade pip
sudo systemctl start docker
sudo groupadd docker
sudo usermod -aG docker $USER
sudo mount /dev/xvda1 /home/$USER/wandb_diskspace
python3 -m pip install --ignore-installed --upgrade pip
python3 -m pip install --ignore-installed wandb==${wandb_version}
docker volume create --driver local --opt type=none --opt device=/home/$USER/wandb_diskspace --opt o=bind wandb_volume
nohup wandb server start --port ${ec2_application_port} \
    -e AWS_REGION=${aws_region} \
    -e MYSQL=mysql://${db_instance_username}:${db_instance_password}@${db_instance_endpoint}/${db_instance_name} \
    # TODO: Need to fix this!
    # -e BUCKET=s3://${bucket_id} \
    # -e BUCKET_QUEUE=${bucket_queue} \
    -v /home/$USER/wandb_diskspace:/vol \
    --daemon &
