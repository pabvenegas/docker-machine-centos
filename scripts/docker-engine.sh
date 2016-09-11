#!/bin/bash

set -x

echo '=============================================================='
echo '================= Install Docker Engine ======================'
echo '=============================================================='

# install docker cs
sudo rpm --import "https://pgp.mit.edu/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://packages.docker.com/${INSTALL_DOCKER_VERSION}/yum/repo/main/centos/7
sudo yum install docker-engine -y

# start docker service
sudo systemctl enable docker.service
sudo service docker start

#  allow vagrant user to run docker commands
sudo usermod -a -G docker vagrant
sudo chown -R vagrant:root /var/lib/docker/
sudo chown -R vagrant:root /etc/docker/

