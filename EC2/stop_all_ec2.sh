#!/usr/bin/env bash

export instanceID=$(aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[InstanceId]' --output text)

if [[ $instanceID = *"None"* || -z $instanceID ]]
then {
  echo "No instances are currently running"
}

else {
  echo "Stopping instances: "
  echo $instanceID
  aws ec2 stop-instances --instance-id $instanceID
}
fi


echo "Checking for stopped instances..."
export stoppedInstanceID=$(aws ec2 describe-instances --filter "Name=instance-state-name,Values=stopped" --query 'Reservations[*].Instances[*].[InstanceId]' --output text)

if [[ $stoppedInstanceID = *"None"* || -z $stoppedInstanceID ]]
then
  echo "No previously stopped instances, exiting script."
else
  echo "Instances found: "
  echo $stoppedInstanceID
  echo "Would you like to terminate these instances (Y/N)?"
  read terminateAnswer

  if [ "$(echo "$terminateAnswer"| tr '[:upper:]' '[:lower:]')" = "y" ]
  then
    aws ec2 terminate-instances --instance-id $stoppedInstanceID
  else
    exit 1
  fi
fi
