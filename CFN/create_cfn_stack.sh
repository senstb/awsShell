#!/usr/bin/env bash

echo "Please specify stack name: "
read stackName

echo "Please specify template: "
read template

export keyName=$(aws ec2 describe-key-pairs | jq -r '.KeyPairs | sort_by(.CreationDate) | last(.[]).KeyName')

aws cloudformation create-stack --stack-name $stackName --template-body file://$template --parameters ParameterKey=KeyPair,ParameterValue=$keyName
