#!/bin/bash

# demand to run as sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Configure the required variables
clear
wp_db_name="wordpress"

echo "Enter a wordpress username (used as database username and wordpress admin username): "
read wordpress_user
echo "Enter the root password for wordpress (used as MySql root password, db password and admin password): "
echo -n Password:
read -s wordpress_password
echo

# Update the system
clear
sudo apt update -y
sudo apt upgrade -y

# Install the required packages
clear
echo "Installing required packages..."
sudo apt install -y apache2 php php-mysql mysql-server php-curl php-gd php-intl php-mbstring php-soap php-xml \
php-xmlrpc php-zip php-json libapache2-mod-php

# Download and extract the latest version of WordPress
clear
echo "Configuring the database..."
cd /tmp/
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
sudo mv wordpress/* /var/www/html
sudo rm -rf wordpress latest.tar.gz

# Set permissions for WordPress
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Create a MySQL database for WordPress (https://wordpress.org/documentation/article/creating-database-for-wordpress/)
sudo mysql -u root -p"$wordpress_password" -e "CREATE DATABASE $wp_db_name;"
sudo mysql -u root -p"$wordpress_password" -e "GRANT ALL PRIVILEGES ON $wp_db_name.* TO '$wordpress_user'@'localhost' IDENTIFIED BY '$wordpress_password';"
sudo mysql -u root -p"$wordpress_password" -e "FLUSH PRIVILEGES;"
sudo mysql -u root -p"$wordpress_password" -e "EXIT;"

# Rename the WordPress sample configuration file and configure it
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/$wp_db_name/g" /var/www/html/wp-config.php
sudo sed -i "s/username_here/$wordpress_user/g" /var/www/html/wp-config.php
sudo sed -i "s/password_here/$wordpress_password/g" /var/www/html/wp-config.php
sudo rm -rf /var/www/html/index.html

# change the file ownership and permissions of the WordPress files and folders
# so that they can be modified by the web server.
sudo chown -R www-data:www-data /var/www/html
#sudo find /var/www/html -type d -exec chmod 750 {} \;
#sudo find /var/www/html -type f -exec chmod 640 {} \;

# reload apache2
sudo sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
sudo a2enmod rewrite
sudo systemctl reload apache2

# Enable ftp connection to wordpress
sudo sed -i "s/;ftp/ftp/g" /etc/php/7.4/apache2/php.ini
sudo systemctl reload apache2


# Launch the WordPress installation in a web browser
clear
echo "Installation complete!"
echo "Access your WordPress site at http://<your-instance-ip>/wp-admin/install.php"