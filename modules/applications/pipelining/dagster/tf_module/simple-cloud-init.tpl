#!/bin/bash

USER=ec2-user
VERSION=${vs_code_version}

# Install Dagster dependencies
sudo yum update -y
sudo yum -y install python3 python3-pip
python3 -m pip install --upgrade pip

# install visual studio code server
mkdir -p /home/$USER/.cache/code-server
curl -#fL -o /home/$USER/.cache/code-server/code-server-$VERSION-amd64.rpm.incomplete -C - https://github.com/coder/code-server/releases/download/v$VERSION/code-server-$VERSION-amd64.rpm
mv /home/$USER/.cache/code-server/code-server-$VERSION-amd64.rpm.incomplete /home/$USER/.cache/code-server/code-server-$VERSION-amd64.rpm
sudo rpm -U /home/$USER/.cache/code-server/code-server-$VERSION-amd64.rpm

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

DAGSTER_HOME=/home/$USER/dagster/${project_name} nohup dagster dev -h 0.0.0.0 -p ${ec2_application_port} &
code-server --auth none --bind-addr 0.0.0.0:9500 -an ${project_name} --open /home/$USER/dagster/${project_name} --disable-update-check --disable-workspace-trust
