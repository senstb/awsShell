#!/bin/bash

  sudo yum update -y
  sudo yum install -y docker
  sudo yum install -y git

  git clone https://github.com/dockerfile/ubuntu/
  cd ubuntu
  sudo service docker start

  sudo usermod -a -G docker ec2-user
  sudo touch ~/../../var/www/html/index.html
  sudo chkconfig httpd on
