#!/bin/bash
# PREPHOST for docker based multiple websites setup
# Initial update, upgrade, and install of docker and docker-compose

#sudo sed -i "s/devuser/$USER/g" ./add.sh

sudo apt update
sudo apt upgrade
sudo apt install docker.io -y
sudo apt install docker-compose -y
sudo apt install htop -y
sudo apt install pwgen -y
sudo apt install npm -y

#add current user to docker group
#sudo usermod -aG docker $USER # Disabling this because docker group has similar privileges as root. We can use sudo.
sudo usermod -aG sudo $USER

# Create a dockerweb network for linking web container sets

sudo docker network create nginx-proxy
mkdir -p /home/$USER/Dev/projects

cd $PWD/nginx-proxy/ && sudo docker-compose up -d && cd ..
cd $PWD/adminer/ && sudo docker-compose up -d && cd ..
cd $PWD/portainer/ && sudo docker-compose up -d && cd ..

touch used_ports
