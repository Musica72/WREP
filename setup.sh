#!/usr/bin/env bash
set -o errexit

# script must be started with sudo privileges or root user - root user always 0!
if [ "$(id -u)" -ne 0 ]
then
    echo "Please run as root!"
    exit 2
fi

# Variables
download="$(wget https://wordpress.org/latest.tar.gz)"
unzip="$(tar -xvzf latest.tar.gz)" 
home="/home/${USER}"  #global variable $HOME exists, but i think this is more appropriate.
repo="${home}/WREP"
ngdir="/usr/share/nginx/"
confs="${repo}/CONFS"
ndef="/etc/nginx/sites-available/"
phpdef="/etc/php/7.2/fpm/pool.d/"
wploc="${ngdir}/wordpress/"
dnsloc="/etc/bind/"
    
# define functions -> apt-get check is fine, but not needed since package names can vary on different linux distributions (hence, this must be run on ubuntu/debian where apt-get is present)
install() {
    apt-get install "${1}"
}
add_repo() {
    apt-add-repository -y install ppa:"${1}"
}
update(){
    apt-get update
}
upgrade(){
    apt-get upgrade
}
     
# add package repositories - add-apt-repository only makes package available for download, refreshes the package list -> does not install them!
add_repo nginx/stable
add_repo install ondrej/php7.2-fpm
     
# only needed once after repositories are added -> to refresh package list
update

# install packages
install nginx
echo "NGINX is installed."
     
install mysql5.6-server
echo "MYSQL is installed."
     
install php7.2-fpm
echo "PHP-fpm is installed."
     
install squid
echo "Proxy server is installed."
   
install bind9
echo "DNS server is installed."

# get Wordpress
get_latest_wp() {
    cd ${home}
    ${download}
    ${unzip}
    cp "${home}/wordpress" ${ngdir}
}

get_latest_wp 
echo "Wordpress is installed."

# Copy configuration files 
cp ${confs}/www.conf ${phpdef}
cp ${confs}/default  ${ndef}
cp ${confs}/wp-config.php ${wploc}
cp -avr ${repo} ${dnsloc}
   
# Allow firewall
firewall (){
 ufw allow 22 #ssh
 ufw allow 3306 #mysql
 ufw allow 443 #https
 ufw allow 80 #http
 ufw allow 9000 #for php
 ufw allow 53 #if connects to dns
}

firewall
 
# all good, exit now
exit 0
