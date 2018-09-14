#!/bin/bash

echo "Please enter name for instance: "
read instanceName

nameValue="ResourceType=instance,Tags=[{Key=Name,Value=$instanceName}]"

if [[ -z $(command -v jq) ]]
then
  echo "Error in script: "
  echo "JQ application required to run script. Please review documentation for installation at https://stedolan.github.io/jq/"
  exit 1
fi

export instAmi=$(aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2' 'Name=state,Values=available' | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')

export keyName=$(aws ec2 describe-key-pairs | jq -r '.KeyPairs | sort_by(.CreationDate) | last(.[]).KeyName')

if [ -f ./startup.sh ]
then
  export instance=$(aws ec2 run-instances --image-id $instAmi --instance-type t2.micro --key-name $keyName --tag-specifications $nameValue --user-data file://startup.sh)
else
  export instance=$(aws ec2 run-instances --image-id $instAmi --instance-type t2.micro --key-name $keyName --tag-specifications $nameValue)
fi
