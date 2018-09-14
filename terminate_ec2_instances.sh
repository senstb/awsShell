#!/bin/bash

echo "Checking for stopped instances..."

export stoppedInstanceID=$(aws ec2 describe-instances --filter "Name=instance-state-name,Values=stopped" --query 'Reservations[*].Instances[*].[InstanceId]' --output text)

echo "Instances found:"
i=0
declare -a instID

for id in $stoppedInstanceID
do {
  instID[$i]=$id
  i=$(($i+1))
  echo $i")" $id
}
done
i=$(($i+1))
echo $i") All Instances"
echo "Which instance would you like to terminate?"
read selection

if [ $selection -eq $i ]
then {
  echo "Deleting all instances..."
  #aws ec2 terminate-instances --instance-id $stoppedInstanceID
}
elif [[ $selection -lt $i ]  && [ $selection -gt 0 ]]
then {
  echo "Selection is invalid, exiting script."
}
else {

  echo "Deleting..."
  echo ${instID[$(($selection-1))]}
  #aws ec2 terminate-instances --instance-id ${instID[$(($selection-1))]}
}
fi
