#!/bin/bash

echo "Checking for current active access keys..."

activeKey=$(aws iam list-access-keys)

if [[ -z $(echo $activeKey | jq .AccessKeyMetadata[1]) ]]
then
  echo "Already two keys existing, exiting script..."
  exit
fi

user=$(echo $activeKey | jq .AccessKeyMetadata[0].UserName -r)
oldKey=$(echo $activeKey | jq .AccessKeyMetadata[0].AccessKeyId -r)

echo "Creating new access key"
newKey=$(aws iam create-access-key --user-name $user)

newKeyId=$(echo $newKey | jq .AccessKey.AccessKeyId -r)
newSecretKey=$(echo $newKey | jq .AccessKey.SecretAccessKey -r)

echo "Marking old key as inactive..."
aws iam update-access-key --access-key-id $oldKey --status Inactive --user-name $user
echo "Key Rotation is complete."

echo "Would you like to delete the inactive key?"
echo "KeyId: " $oldKey " (y/n)"
read response

if [ "$(echo "$response"| tr '[:upper:]' '[:lower:]')" = "y" ]
then
    echo "Deleting old key..."
    aws iam delete-access-key --user-name $user --access-key-id $oldKey
fi

echo "Updating local AWS CLI settings..."
aws configure set aws_access_key_id $newKeyId
aws configure set aws_secret_access_key $newSecretKey
echo "New ID: " $newKeyId
echo "New Secret ID: " $newSecretKey
