#!/bin/bash
sudo yum update -y
sudo yum -y install python3 python3-pip docker
python3 -m pip install --upgrade pip
sudo systemctl start docker
sudo groupadd docker
sudo usermod -aG docker $USER
python3 -m pip install --ignore-installed --upgrade pip
python3 -m pip install --ignore-installed wandb==${wandb_version}
nohup wandb server start --port ${ec2_application_port} --daemon &
