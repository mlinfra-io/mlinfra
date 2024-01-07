#!/bin/bash
sudo yum update -y
sudo yum -y install python3 python3-pip
python3 -m pip install --upgrade pip
python3 -m pip install --ignore-installed psycopg2-binary==2.9.6 mlflow==${mlflow_version}
nohup mlflow server \
        --host 0.0.0.0 \
        --port ${ec2_application_port} \
        --backend-store-uri postgresql://${db_instance_username}:${db_instance_password}@${db_instance_endpoint}/${db_instance_name} \
        --default-artifact-root s3://${bucket_id} \
        --artifacts-destination s3://${bucket_id}/mlflow-artifacts &
