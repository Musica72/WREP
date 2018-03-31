set -o errexit
     
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
     
# wget is the name of the command -> name functions with valid and resonable names
get_latest_wp() {
    cd ~ # its better to have an absolute pat to folder, also /tmp or others are more approppriate then /root...
    wget https://wordpress.org/latest.tar.gz # also variables...use them, define them on top of the script
    tar -xvzf latest.tar.gz
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
     
get_latest_wp
echo "Wordpress is installed."
     
install squid
echo "Proxy server is installed."
   
install bind9
echo "DNS server is installed."
    
# all good, exit now
exit 0
