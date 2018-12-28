#!/bin/bash
# PREPHOST for docker based multiple websites setup
# Initial update, upgrade, and install of docker and docker-compose

#sudo sed -i "s/devuser/$USER/g" ./add.sh

sudo apt update
sudo apt upgrade
modprobe aufs
sudo snap install docker
sudo apt install docker-compose htop npm composer php-xml -y

#add current user to docker group
#sudo usermod -aG docker $USER # Disabling this because docker group has similar privileges as root. We can use sudo.
sudo usermod -aG sudo $USER

# Create a dockerweb network for linking web container sets

sudo docker network create nginx-proxy
mkdir -p /home/$USER/Dev/projects

cd $PWD/scripts/nginx-proxy && sudo docker-compose up -d && cd ..
cd $PWD/scripts/adminer && sudo docker-compose up -d && cd ..
cd $PWD/scripts/portainer && sudo docker-compose up -d && cd ..

touch used_ports
