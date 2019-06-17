#!/bin/bash

set -e

groupadd -g 1000 elk-servers
useradd -u 1000 -g 1000 -d /home/elk-servers -s /sbin/nologin elk-servers

curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


echo "
############################### ELK ##############################
# disable ipv6
net.ipv6.conf.all.disable_ipv6 = 1  
net.ipv6.conf.default.disable_ipv6 = 1  
net.ipv6.conf.lo.disable_ipv6 = 1  

vm.swappiness=1
vm.max_map_count=262144
############################# ELK End ############################
" >> /etc/sysctl.conf
sysctl -p

