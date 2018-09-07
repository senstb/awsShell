#!/usr/bin/env bash

export instanceID=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceID]' --output text)

if [[ $instanceID = *"None"* ]]; then {
  echo "No instances are currently running"
}

else {
  echo "Stopping instances: "
  echo $instanceID
  aws ec2 stop-instances --instance-id $instanceID
}

fi
