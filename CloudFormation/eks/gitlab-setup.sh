#!/bin/bash

# Config convenience
sudo echo 'alias vi=vim' >> /etc/profile
sudo echo "sudo su -" >> /home/ec2-user/.bashrc

# Change Timezone
sudo sed -i "s/UTC/Asia\/Seoul/g" /etc/sysconfig/clock
sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Update yum
sudo yum update -y

# Install Tools
sudo yum -y install tree jq git htop lynx

# Install Docker
sudo amazon-linux-extras install docker -y
sudo systemctl start docker && sudo systemctl enable docker

# Change Docker network

cat /etc/docker/daemon.json
sudo sed -i "s/UTC/Asia\/Seoul/g" /etc/sysconfig/clock

# Install docker-compose-plugin
sudo curl \
    -SL "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
## 설치 확인
docker-compose --version


# # Install kubectl & helm (kubernetes에 배포용)
# sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.25.7/2023-03-17/bin/linux/amd64/kubectl
# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# sudo curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Install let`s encrypt with Nginx
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#sudo yum install -y certbot python3-certbot-apache mod_ssl
sudo yum install -y certbot python-certbot-nginx
# 설치 확인
certbot --version
