#!/bin/bash
# Reset the LDE scripts and uninstall the environment

cd $PWD/nginx-proxy/ && docker-compose down
cd $PWD/adminer/ && docker-compose down
cd $PWD/portainer/ && docker-compose down

sudo usermod -aG docker $USER

sudo docker network rm nginx-proxy

sudo apt remove docker -y
sudo apt remove docker-compose -y
sudo apt remove npm -y

> used_ports
