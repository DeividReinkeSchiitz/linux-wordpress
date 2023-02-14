#!/bin/bash

# Shell script to install wordpress on linux machine
# Tested in Ubuntu 22.04

# demand to run as sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Step 1: Configure the required variables
clear
wp_db_name="wordpress"

echo "Enter a wordpress username (used as database username and wordpress admin username): "
read wordpress_user
echo "Enter the root password for wordpress (used as MySql root password, db password and admin password): "
read wordpress_password

# Step 2: Update the system
sudo apt update
sudo apt upgrade

# Step 3: Install the required packages
clear
echo "Installing packages on the system.."
sudo apt-get install apache2 -y
sudo apt-get install php libapache2-mod-php -y

# Install PostgreSQL
sudo apt-get install postgresql postgresql-contrib -y

# Install PHP extensions for PostgreSQL
sudo apt-get install php-pgsql -y

# Create a PostgreSQL user and database for WordPress
sudo -u postgres psql -c "CREATE USER $wordpress_user WITH PASSWORD '$wordpress_password';"
sudo -u postgres psql -c "CREATE DATABASE $wp_db_name OWNER $wordpress_user;"

# Step 4: Configure the web and database servers to run at startup
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Step 5: : Download the wordpress package
clear
echo "Downloading the wordpress package.."
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo mv wordpress /var/www/html/wordpress
sudo rm -rf latest.tar.gz

# Configure Apache to serve WordPress
sudo cat << EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html/wordpress
    ServerName example.com
    ServerAlias www.example.com
    <Directory /var/www/html/wordpress>
        AllowOverride All
    </Directory>
    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF
sudo a2ensite wordpress.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2

# Copy the WordPress configuration file
sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

# Replace the placeholders in the WordPress configuration file with the actual values
sudo sed -i "s/database_name_here/$wp_db_name/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/$wordpress_user/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/$wordpress_password/" /var/www/html/wordpress/wp-config.php

# Launch the WordPress installation in a web browser
echo "Access your WordPress site at http://<your-ec2-instance-ip>/wordpress"