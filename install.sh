# Shell script to install wordpress on linux machine
# Tested in Ubuntu 22.04

# Step 1: Update the system
sudo apt update
sudo apt upgrade

# Step 2: Configure the required environment variables
# Step 2.1: Get password from user
clear
echo "Enter the username for wordpress: "
read -s wordpress_user
echo "Enter the root password for wordpress: "
read -s wordpress_password

# Step 2.2: Set the environment variables
export DB_NAME="wordpress"
export DB_USER=wordpress_user
export DB_PASSWORD=wordpress_password

# Step 3: Install the required packages
clear
echo "Installing packages on the system.."
sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql

# Step 4: Configure the web and database servers to run at startup
sudo systemctl enable apache2
sudo systemctl enable mysql
sudo systemctl start apache2
sudo systemctl start mysql

# Step 5: Create the database and user for wordpress
clear
echo "Configuring the database and web server.."
mysql -u root -pDB_PASSWORD -e "CREATE DATABASE $DB_NAME; CREATE USER $DB_USER@localhost IDENTIFIED BY '$DB_PASSWORD'; GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost; FLUSH PRIVILEGES;"

# Step 6: Download the wordpress package
clear
echo "Downloading the wordpress package.."
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo mv wordpress/* /var/www/html/
