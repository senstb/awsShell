#!/bin/bash

echo "Please enter name for instance: "
read instanceName

export instAmi=$(aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2' 'Name=state,Values=available' | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')

export keyName=$(aws ec2 describe-key-pairs | jq -r '.KeyPairs | sort_by(.CreationDate) | last(.[]).KeyName')

export instance=$(aws ec2 run-instances --image-id $instAmi --instance-type t2.micro --key-name $keyName --tag-specifications 'ResourceType=instance,Tags=[{Key=instance,Value= Test }]' --user-data file://startup.sh)

echo $instance | grep PublicIpAddress
