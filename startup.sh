#!/bin/bash

sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo yum install -y httpd
sudo touch ~/../../var/www/html/index.html
sudo service httpd start
sudo chkconfig httpd on
