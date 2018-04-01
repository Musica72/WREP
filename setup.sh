#!/usr/bin/env bash
set -o errexit

download="$(wget https://wordpress.org/latest.tar.gz)"
unzip="$(tar -xvzf latest.tar.gz)" 
home="/home/${USER}"  #global variable $HOME exists, but i think this is more appropriate.
repo="${home}/WREP"
get_repo="$(git clone https://github.com/Musica72/WREP.git)" 
ngdir="/usr/share/nginx/"
confs="${repo}/CONFS"
ndef="/etc/nginx/sites-available/"
phpdef="/etc/php/7.2/fpm/pool.d/"
wploc="${ngdir}/wordpress/"

# much nicer solution / root user id is always 0 (or sudo when privileges are elevated) -> 'exec' is dangerous!
# script must be started with sudo privileges or root user
if [ "$(id -u)" -ne 0 ]
then
    echo "Please run as root!"
    exit 2
fi
     
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

# get Wordpress
get_latest_wp() {
    cd ${home}
    ${download}
    ${unzip}
    cp "${home}/wordpress" ${ngdir}
}
     
# install packages
install nginx
echo "NGINX is installed."
     
install mysql5.6-server
echo "MYSQL is installed."
     
install php7.2-fpm
echo "PHP-fpm is installed."
     
get_latest_wp
echo "Wordpress is installed."
     
install squid
echo "Proxy server is installed."
   
install bind9
echo "DNS server is installed."

# Get configuration files from Git repository (with assumption that GIT was pre-installed on the system)
cd ${home}
${get_repo}

# Copy configuration files 
cp $confs/www.conf ${phpdef}
cp $confs/default  ${ndef}
cp $confs/wp-config.php ${wploc}

    
# all good, exit now
exit 0
