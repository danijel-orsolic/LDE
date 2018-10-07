This is a simple but powerful way of deploying a local development environment (LDE) without resorting to something like XAMPP.

The only prerequisites are Vagrant and VirtualBox. On Windows you may also need something like [Mountain Duck](https://mountainduck.io/) if you want to be able to access the VM filesystem from your host, since Vagrant FS has issues with symlinks that are needed for things like NPM.

To allow setting the virtual disk size install the vagrant disksize plugin:

`vagrant plugin install vagrant-disksize`

Once you've got that just clone the repo and run `vagrant up`. 

Then you can enter your VM by running `vagrant ssh`.

Once inside you can run ./add.sh script, which automates setting up project environments and containers for a few stacks, like WordPress, legacy LAMP with PHP5, and the LEMP stack with PHP7.

## Benefits

* It works the same on Windows, Linux and Mac. No need for XAMPP. You get Linux anywhere, which is what's most used in production environments as well.

* Multiple virtual hosts out of the box. Thanks to nginx-proxy this single VM can host multiple projects each with their own local domain name. 

* Infinite options of stacks - since each project is a Docker stack they can run whatever you want within them. Just need to modify docker-compose files. And if you don't want to run a project in docker you don't have to. Just run them on a port.

## How it works

Running vagrant up, according to the VagrantFile configuration, will set up an Ubuntu 18.04 LTS Bionic VM and run a prep.sh script within it. This installs docker and a bunch of other useful tools, and creates a docker set up with an nginx-proxy container and network to support automatic resolving of virtual hosts. It reads the VIRTUAL_HOST environment variable from docker-compose.yml in your project.

The add.sh script automates the project creation task for a few cases, like creating a project stack for WordPress, LAMP with PHP5, and LEMP.

The project set up automation is hardcoded to use the /home/vagrant/projects directory for your projects, and the vagrant user for running everything, but you can modify the scripts however you wish.

The way automation of project creation with add.sh works is pretty simple. It copies base docker-compose.yml and some associated files of a chosen stack (residing in, for example, scripts/lemp_base), and then replaces placeholder strings like namegoeshere, domaingoeshere etc. with your own inputs. The final docker-compose.yml in the project folder is then ran with `docker-compose up -d`.

## Notes:

The scripts were first created as a way of deploying a Docker based web hosting environment, and then adapted for the purpose of deploying a Vagrant based local development environment.

The LEMP stack set up is adapted from [Frekans7 Docker Compose LEMP stack](https://github.com/frekans7/docker-compose-lemp)

If you have problems with disksize remove or comment out the `config.disksize.size = '20GB'` line from VagrantFile and rerun vagrant up.

This is more of a personal project without guarantees, but if you find it useful go for it! 

## TODO

* Adapt the readme - this is now meant to support an option of deploying as a local dev environment in Ubuntu without a VM