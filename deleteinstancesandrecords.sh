#!/bin/bash

Hosting_ID="Z03338611JYIFQWLKNVHI"
# INSTANCES=$(aws ec2 describe-instances \
#   --filters "Name=instance-state-name,Values=running" \
#   --query "Reservations[].Instances[?Tags[?Key=='Name' && Value!='roboshop'] && Tags[?Key=='Name']].InstanceId" \
#   --output text
# )

# if [ -z "$INSTANCES" ]; then
#   echo "No instances to terminate"
#   exit 0
# fi
# read -p "Are you sure you want to terminate these instances? (yes/no): " CONFIRM
# if [ "$CONFIRM" != "yes" ]; then
#   echo "Aborted"
#   exit 1
# fi

# echo "Terminating instances:"
# echo "$INSTANCES"

# aws ec2 terminate-instances --instance-ids $INSTANCES
# echo "Deleted all running instance other than roboshop"


INSTANCES=$( aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[?Tags[?Key=='Name' && Value!='roboshop']].InstanceId" \
    --output text
)

aws ec2 terminate-instances --instance-ids $INSTANCES
echo "Deleted all running instance other than roboshop"


# aws route53 change-resource-record-sets \
#     --hosted-zone-id $Hosting_ID \
#     --change-batch "$(aws route53 list-resource-record-sets \
#         --hosted-zone-id $Hosting_ID \
#         --query "ResourceRecordSets[?Type!='NS' && Type!='SOA']" \
#         --output json | jq '{Changes: map({Action: "DELETE", ResourceRecordSet: .})}')"

# echo "Deleted all R53 Records other than NS and SOA Types"