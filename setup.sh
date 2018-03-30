#!/usr/bin/env bash
set -o errexit

# run as root
[ "${USER:-}" = "root" ] || exec sudo "$0" "$@"

install() {
  if [-n "{which apt-get}" ];
  then apt-get install;
  elif [-n "{which apt-add-repository}" ];
  then apt-add-repository -y install ppa: ;
  fi;
}

wget() {
 cd ~
 wget https://wordpress.org/latest.tar.gz
 tar -xvzf latest.tar.gz
}

upd(){
 apt-get update
}

upg(){
 apt-get upgrade
}
install nginx/stable
upd
echo "NGINX is installed."
install mysql5.6-server
echo "MYSQL is installed."
upd
install ondrej/php7.2-fpm
upd
echo "PHP-fpm is installed."
upd
wget 
install
echo "Wordpress is installed."
upd
install squid
echo "Proxy server is installed."
upd
install bind9
echo "DNS server is installed."
upg
