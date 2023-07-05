#!/bin/bash

USER=ec2-user

# Install Dagster dependencies
sudo yum update -y
sudo yum -y install python3 python3-pip
python3 -m pip install --upgrade pip

# Mount EBS volume
mkdir /home/$USER/dagster
sudo chown -R $USER:$USER /home/$USER/dagster
sudo mount /dev/xvda1 /home/$USER/dagster
cd /home/$USER/dagster

# Install Dagster and required packages
python3 -m pip install --ignore-installed dagster==${dagster_version} dagit==${dagit_version}

# setting up project
dagster project scaffold --name ${project_name}
cd ${project_name}/

# Install python requirements
python3 -m pip install -e ".[dev]"
# Add any additional setup or configuration here
echo "${dagster_config}" > dagster.yaml

DAGSTER_HOME=/home/$USER/dagster/${project_name} nohup dagster-daemon run &
DAGSTER_HOME=/home/$USER/dagster/${project_name} nohup dagit -h 0.0.0.0 -p ${ec2_application_port} &
