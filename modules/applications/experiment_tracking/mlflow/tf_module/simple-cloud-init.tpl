#!/bin/bash
sudo yum update -y
sudo yum -y install python3 python3-pip
python3 -m pip install --upgrade pip
python3 -m pip install --ignore-installed mlflow==${mlflow_version}
nohup mlflow server --host 0.0.0.0 --port ${ec2_application_port} &
