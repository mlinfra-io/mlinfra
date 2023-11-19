#!/bin/bash
sudo yum update -y
sudo yum -y install wget

wget --compression=auto "https://github.com/treeverse/lakeFS/releases/download/v${lakefs_version}/lakeFS_${lakefs_version}_$(uname -s)_$(uname -m).tar.gz"
tar -xzvf "lakeFS_${lakefs_version}_$(uname -s)_$(uname -m).tar.gz"
rm "lakeFS_${lakefs_version}_$(uname -s)_$(uname -m).tar.gz"
sudo mv lakefs /usr/local/bin/lakefs
sudo chmod +x /usr/local/bin/lakefs

sudo mv lakectl /usr/local/bin/lakectl
sudo chmod +x /usr/local/bin/lakectl

sudo mv delta_diff /usr/local/bin/delta_diff
sudo chmod +x /usr/local/bin/delta_diff

echo "${lakefs_config}" > /home/ec2-user/config.yaml
sudo chown ec2-user:ec2-user /home/ec2-user/config.yaml
nohup lakefs run --config /home/ec2-user/config.yaml &
