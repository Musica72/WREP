set -o errexit

# script must be started with sudo privileges or root user - root user always 0!
if [ "$(id -u)" -ne 0 ]
then
    echo "Please run as root!"
    exit 2
fi

# Variables
wpurl='https://wordpress.org/latest.tar.gz'
wpfile='latest.tar.gz' 
home="/root"  #global variable $HOME exists, but i think this is more appropriate.
repo="${home}/WREP"
mysql_root_user="root"
mysql_root_pass="root"
mysql_wp_db="wordpress"
mysql_wp_user="wordpressuser"
mysql_wp_pass="wordpress"
giturl='https://github.com/Musica72/WREP'
ngdir="/usr/share/nginx/"
confs="${repo}/CONFS"
ndef="/etc/nginx/sites-available/"
phpdef="/etc/php/7.2/fpm/pool.d/"
wpdir="${home}/wordpress"
wploc="${ngdir}/wordpress/"
dnsloc="/etc/bind/"
    
# define functions -> apt-get check is fine, but not needed since package names can vary on different linux distributions (hence, this must be run on ubuntu/debian where apt-get is present)
install() {
    apt-get install -y "${1}"
}
add_package_repository() {
    apt-add-repository -y ppa:"${1}" 
}
update(){
    echo "Running update..."
    apt-get -qq update
}
     
# add package repositories - add-apt-repository only makes package available for download, refreshes the package list -> does not install them!
#add_package_repository nginx/stable
#add_package_repository ondrej/php
     
# only needed once after repositories are added -> to refresh package list
#update

# install packages
#install nginx
echo "NGINX is installed."
     
#debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password password "'${mysql_root_pass}'"'
#debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password_again password "'${mysql_root_pass}'"'
#install mysql-server-5.6
echo "MYSQL is installed."
     
#install php7.2-fpm php7.2-mysql 
echo "PHP-fpm is installed."
     
#install squid
echo "Proxy server is installed."
   
#install bind9
echo "DNS server is installed."

# get Wordpress
get_latest_wp() {
    cd "${home}"
    wget "${wpurl}"
    tar -xvzf "${wpfile}"
    cp -avr "${wpdir}" "${ngdir}"
}

#get_latest_wp 

#echo "Wordpress is installed."

# get repo
get_git_repository () {
 cd "${home}"
 git clone "${giturl}"
}

#get_git_repository

# Copy configuration files 
#cp -r "${confs}/www.conf" "${phpdef}"
#cp -r "${confs}/default"  "${ndef}"
#cp -r "${confs}/wp-config.php" "${wploc}"
#cp -avr "${repo}" "${dnsloc}"

# Removing extra files
delete_extra_files () {
 rm -f "${wpfile}"
 rm -rf "${wpdir}"
 rm -rf "${repo}"
}

#delete_extra_files
   
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

#firewall

# Restart configuration
restart_configuration () {
 nginx -t && service nginx restart
 service php7.2-fpm restart
 service mysql restart
 service bind9 restart
 service squid3 restart 
}

restart_configuration

# Create MYSQL DATABASE
create_mysql_db () {
mysql --user="${mysql_root_user}" --password="${mysql_root_pass}" --execute="CREATE DATABASE IF NOT EXISTS "${mysql_wp_db}";"
mysql --user="${mysql_root_user}" --password="${mysql_root_pass}" --execute="GRANT ALL PRIVILEGES ON "${mysql_wp_db}".* TO '${mysql_wp_user}'@'localhost' WITH GRANT OPTION;"
mysql --user="${mysql_root_user}" --password="${mysql_root_pass}" --execute="FLUSH PRIVILEGES;"
echo "MYSQL has finished with database creation."
}

create_mysql_db
 
# all good, exit now
echo "Everything is fine, bash script has finished it's work."

exit 0
