#!/bin/bash
yum update -y
yum install -y httpd git

# Create the directory and fetch the app
mkdir -p /var/www/html
cd /var/www/html
git clone https://github.com/lavanya24072000/usecases.git
cd web-app
mv index.php /var/www/html/
# Start Apache service
systemctl restart httpd

