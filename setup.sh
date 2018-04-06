#!/usr/bin/env bash
set -o errexit

# script must be started with sudo privileges or root user - root user always 0!
if [ "$(id -u)" -ne 0 ]
then
    echo "Please run as root!"
    exit 2
fi

# Variables
wpurl='https://wordpress.org/latest.tar.gz)'
wpfile='latest.tar.gz' 
home="/root"  #global variable $HOME exists, but i think this is more appropriate.
repo="${home}/WREP"
ngdir="/usr/share/nginx/"
confs="${repo}/CONFS"
ndef="/etc/nginx/sites-available/"
phpdef="/etc/php/7.2/fpm/pool.d/"
wpdir="${home}/wordpress"
wploc="${ngdir}/wordpress/"
dnsloc="/etc/bind/"
    
# define functions -> apt-get check is fine, but not needed since package names can vary on different linux distributions (hence, this must be run on ubuntu/debian where apt-get is present)
install() {
    apt-get install -qq"${1}"
}
add_repo() {
    apt-add-repository -y ppa:"${1}" > /dev/null 2>&1
}
update(){
    apt-get --qq update
}
upgrade(){
    apt-get -qq upgrade
}
     
# add package repositories - add-apt-repository only makes package available for download, refreshes the package list -> does not install them!
add_repo nginx/stable
add_repo ondrej/php
     
# only needed once after repositories are added -> to refresh package list
update

# install packages
install nginx
echo "NGINX is installed."
     
debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password_again password root'
install mysql-server-5.6
echo "MYSQL is installed."
     
install php7.2-fpm 
echo "PHP-fpm is installed."
     
install squid
echo "Proxy server is installed."
   
install bind9
echo "DNS server is installed."

# get Wordpress
get_latest_wp() {
    cd "${home}"
    wget "${wpurl}"
    tar -xvzf "${wpfile}"
    cp "${wpdir}" "${ngdir}"
}

get_latest_wp 
echo "Wordpress is installed."

# Copy configuration files 
cp "${confs}/www.conf" "${phpdef}"
cp "${confs}/default"  "${ndef}"
cp "${confs}/wp-config.php" "${wploc}"
cp -avr "${repo}" "${dnsloc}"

# Removing extra files
del () {
 rm "${dnsloc}/setup.sh"
 rm -rf "${wpfile}"
 rm -rf "${wpdir}"
 rm -rf "${repo}"
}

   
# Allow firewall
firewall (){
 ufw allow 22 #ssh
 ufw allow 3306 #mysql
 ufw allow 443 #https
 ufw allow 80 #http
 ufw allow 9000 #for php
 ufw allow 53 #if connects to dns
 ufw enable 
}

firewall
 
# all good, exit now
exit 0