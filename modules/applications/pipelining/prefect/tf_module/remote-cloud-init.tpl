#!/bin/bash
sudo yum update -y
# might need to install postgresql-contrib
sudo yum -y install python3 python3-pip
python3 -m pip install --upgrade pip
python3 -m pip install --ignore-installed prefect==${prefect_version}
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
EC2_DNS_HOSTNAME=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/public-hostname`
prefect config set PREFECT_API_DATABASE_CONNECTION_URL="postgresql+asyncpg://${db_instance_username}:${db_instance_password}@${db_instance_endpoint}/${db_instance_name}"
prefect config set PREFECT_API_URL="http://$EC2_DNS_HOSTNAME:${ec2_application_port}/api"
nohup prefect server start --host 0.0.0.0 --port ${ec2_application_port} &
