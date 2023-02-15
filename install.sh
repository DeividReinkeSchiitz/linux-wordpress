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
read -s  wordpress_user
echo "Enter the root password for wordpress (used as MySql root password, db password and admin password): "
echo -n Password:
read -s wordpress_password
echo

# Update the system
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
sudo mv wordpress /var/www/html

# Set permissions for WordPress
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Create a MySQL database for WordPress
mysql -u root -p << EOF
CREATE DATABASE $wp_db_name;
CREATE USER '$wordpress_user'@'localhost' IDENTIFIED BY '$wordpress_password';
GRANT ALL PRIVILEGES ON wordpress.* TO '$wordpress_user'@'localhost';
FLUSH PRIVILEGES;
EOF

# Rename the WordPress sample configuration file and configure it
sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo sed -i 's/database_name_here/$wordpress/g' /var/www/html/wordpress/wp-config.php
sudo sed -i 's/username_here/$wordpress_user/g' /var/www/html/wordpress/wp-config.php
sudo sed -i 's/password_here/$wordpress_password/g' /var/www/html/wordpress/wp-config.php


# reload apache2
sudo systemctl reload apache2

# Launch the WordPress installation in a web browser
clear
echo "Installation complete!"
echo "Access your WordPress site at http://<your-ec2-instance-ip>/wordpress"