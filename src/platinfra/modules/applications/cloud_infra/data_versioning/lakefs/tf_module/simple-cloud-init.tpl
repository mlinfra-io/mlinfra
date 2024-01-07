#!/bin/bash
sudo yum update -y

sudo yum -y install docker
sudo systemctl start docker
sudo groupadd docker
sudo usermod -aG docker $USER

nohup docker run --name lakefs                          \
    --rm --publish ${ec2_application_port}:8000         \
    treeverse/lakefs:latest-duckdb                      \
    run --local-settings &
