#!/bin/bash

# This script automates deployment of new websites as docker stacks on virtual hosts. 
# By Danijel Orsolic

# Defining colors

red='\033[0;31m'
green='\033[0;32m'
cyan='\e[0;36m'
NC='\033[0m' # No Color

echo -e "${cyan}Choose the type of stack to deploy: ${NC}"
options=("WordPress" "Clean LEMP Stack" "Clean LAMP PHP7" "Clean LAMP PHP5" "Symfony 4 (No VM or Docker)" "Redirect")
select opt in "${options[@]}"
do
    case $opt in
        "WordPress")
            stack=wp_base
            break
            ;;
        "Clean LEMP Stack")
            stack=lemp_base
            break
            ;;
        "Clean LAMP PHP7")
            stack=lamp_php7_base
            break
            ;;
        "Clean LAMP PHP5")
            stack=lamp_php5_base
            break
            ;;
        "Symfony 4 (No VM or Docker)")
            stack=symfony
            break
            ;;
        "Redirect")
            echo -e "${cyan}Enter domain or subdomain: ${NC}"
            read subdomain
            echo -e "${cyan}Enter address to redirect to: ${NC}"
            read redirect
            echo "server { listen 80; server_name $subdomain; return 301 $redirect; }" > /home/$USER/Dev/projects/nginx-custom-conf/$subdomain.conf
            docker exec -ti nginx-proxy bash -c "service nginx reload"
            exit
            ;;
        *) echo invalid option;;
    esac
done

echo -e "${cyan}Domain name: ${NC}"
read domain

#echo -e "${cyan}Desired username: ${NC}"
#read user
user=$USER

if [[ "$stack" != symfony ]]; then
echo -e "${cyan}E-mail address: ${NC}"
read email
fi

read -r -p "Confirm and continue? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

# Generate $dbrootpass, $pass, $name. 
# SSH functionality disabled for local dev env.

dbrootpass=$(date +%s|sha256sum|base64|head -c 32);
pass=$(pwgen -s 16 1);
name=${domain//[-._]/};
sshport=$(bash findport.sh 2200 1);
appsport=$(bash findport.sh 8000 1);
pmaport=$(bash findport.sh 10000 1);
echo $sshport >> used_ports
echo $appsport >> used_ports
echo $pmaport >> used_ports

# Make the app directory and copy the base docker-compose.yml and Dockerfile there

if [[ "$stack" != symfony ]]; then
mkdir -p /home/$USER/Dev/projects/$domain/app
cp $stack/docker-compose.yml /home/$USER/Dev/projects/$domain/
fi

if [[ "$stack" == lemp_base ]]; then
cp $stack/Dockerfile /home/$USER/Dev/projects/$domain/
mkdir /home/$USER/Dev/projects/$domain/nginx/
mkdir /home/$USER/Dev/projects/$domain/db/
cp $stack/default.conf /home/$USER/Dev/projects/$domain/nginx/
cp $stack/index.php /home/$USER/Dev/projects/$domain/app/
sed -i "s/namegoeshere/$name/g" /home/$USER/Dev/projects/$domain/nginx/default.conf
sed -i "s/domaingoeshere/$domain/g" /home/$USER/Dev/projects/$domain/nginx/default.conf
fi

if [[ "$stack" == lamp_php7_base ]]; then
cp $stack/Dockerfile /home/$USER/Dev/projects/$domain/
fi

#cp $stack/Dockerfile /vagrant/projects/$domain/

# Modify the new docker-compose.yml and Dockerfiles to reflect chosen information
if [[ "$stack" != symfony ]]; then
sed -i "s/dbrootpass/$dbrootpass/g" /home/$USER/Dev/projects/$domain/docker-compose.yml
sed -i "s/namegoeshere/$name/g" /home/$USER/Dev/projects/$domain/docker-compose.yml
sed -i "s/domaingoeshere/$domain/g" /home/$USER/Dev/projects/$domain/docker-compose.yml
sed -i "s/usergoeshere/$user/g" /home/$USER/Dev/projects/$domain/docker-compose.yml
sed -i "s/emailgoeshere/$email/g" /home/$USER/Dev/projects/$domain/docker-compose.yml
sed -i "s/passgoeshere/$pass/g" /home/$USER/Dev/projects/$domain/docker-compose.yml
sed -i "s/2222/$sshport/g" /home/$USER/Dev/projects/$domain/docker-compose.yml
sed -i "s/8181/$pmaport/g" /home/$USER/Dev/projects/$domain/docker-compose.yml

chown -R $USER:$USER /home/$USER/Dev/projects/$domain
fi

# Build the docker image
echo -e "${green}=> Deploying.. ${NC}"

if [[ "$stack" != symfony ]]; then
#cd /vagrant/projects/$domain && docker build -t libervis/$name .
cd /home/$USER/Dev/projects/$domain && sudo docker-compose up -d
fi

#chown -R vagrant:www-data /vagrant/projects/$domain/app

# echo -e "${green}=> Setting up user access.. ${NC}"
# Install WP and base theme
#sleep 20

# docker exec -ti $name apt-get update -y
# docker exec -ti $name apt-get install openssh-server htop nano -y
# docker exec -ti $name bash -c "sed -i -e 's/#Port 22/Port $sshport/g' /etc/ssh/sshd_config"
# docker exec -ti $name useradd $user
# docker exec -ti $name usermod -aG www-data $user
# docker exec -ti $name bash -c "echo \"$user:$pass\" | chpasswd"
# docker exec -ti $name service ssh start

if [[ "$stack" == wp_base ]]; then

echo -e "${green}=> Installing WordPress and plugins.. ${NC}"
sleep 10

sudo docker exec -ti $name bash -c "echo \"define( 'FTP_HOST', 'localhost:$sshport' );\" >> /var/www/html/wp-config.php"
sudo docker exec -ti $name bash -c "echo \"define( 'FTP_USER', '$user' );\" >> /var/www/html/wp-config.php"
sudo docker exec -ti $name bash -c "echo \"define( 'FTP_PASS', '$pass' );\" >> /var/www/html/wp-config.php"
sudo docker exec -ti $name bash -c "echo \"define( 'FS_METHOD', 'direct' );\" >> /var/www/html/wp-config.php"
sudo docker exec -ti $name bash -c "echo \"define( 'FTP_BASE', '/var/www/html/' );\" >> /var/www/html/wp-config.php"
sudo docker exec -ti $name bash -c "chown -R $user:www-data /var/www/html/*"
sudo docker exec -ti $name bash -c "chmod g+wx -R /var/www/html/*"
sudo docker exec -ti $name bash -c "chown -R $user:www-data /var/www/html"
sudo docker exec -ti $name bash -c "chmod g+wx -R /var/www/html"
fi

if [[ "$stack" == symfony ]]; then

mkdir /home/$USER/Dev/projects/$name/
cd /home/$USER/Dev/projects/$name
composer create-project symfony/skeleton $name
composer require symfony/web-server-bundle --dev
cd /home/$USER/Dev/projects/$name/$name
php -S 127.0.0.1:$appsport -t public

fi

fi # Ends the confirmation loop for domain, user, and email

# Dispay the information:

if [[ "$stack" != symfony ]]; then

localip=$(hostname -i)

sudo -- sh -c "echo \"$localip $domain\" >> /etc/hosts"

echo -e "${cyan}Domain: $domain ${NC}"
echo -e "${cyan}Username: $user ${NC}"
echo -e "${cyan}Password: $pass ${NC}"
echo -e "${cyan}MySQL root password: $dbrootpass ${NC}"

fi