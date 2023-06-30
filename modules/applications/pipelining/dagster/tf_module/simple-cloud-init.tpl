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

# Install Dagster and required packages
python3 -m pip install --ignore-installed dagster==${dagster_version} dagit==${dagit_version}

# Add any additional setup or configuration here
echo "${dagster_config}" > /home/$USER/dagster/dagster.yaml

# setting up sample project
dagster project from-example --name dagster_tutorial_project --example tutorial_dbt_dagster
cd dagster_tutorial_project/
python3 -m pip install -e ".[dev]"
cd tutorial_finished

DAGSTER_HOME=/home/$USER/dagster nohup dagit -h 0.0.0.0 -p ${ec2_application_port} &
