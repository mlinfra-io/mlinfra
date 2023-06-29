#!/bin/bash

# Install Dagster dependencies
sudo yum update -y
sudo yum -y install python3 python3-pip
python3 -m pip install --upgrade pip

# Install Dagster and required packages
python3 -m pip install --ignore-installed dagster==${dagster_version} dagit==${dagit_version}

# Add any additional setup or configuration here

# Start Dagster server
# dagster api grpc serve
