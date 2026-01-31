#!/bin/bash
# export PATH=$PATH:/usr/local/bin
Userid=$(id -u)
SG_ID="sg-01d73528856414fb1"
AMI_ID="ami-0220d79f3f480ecf5"
DOMAIN_NAME="devops88s.online"
Hosting_ID="Z03338611JYIFQWLKNVHI"
R='\e[31m'
G='\e[32m'
Y='\e[33m'
B='\e[34m'
N='\e[0m'   # No Color

# log_folder="/var/log/shellscript"
# log_file="/var/log/shellscript/$0.log"
# if [ $Userid -ne 0 ]; then
# echo -e "$R this is not sudo user $N" | tee -a $log_file
# exit 1
# fi
# mkdir -p $log_folder
# # Package=$1
# validate (){
#     if [ $1 -eq 0 ]; then 
# echo -e "$Package installation $G Success $N" | tee -a $log_file
# else 
# echo -e "$Package installation $R failure $N" | tee -a $log_file
# fi
# }
for instance in $@
do
    INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

    if [ $instance == "frontend" ]; then
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )
         RECORD_NAME="$DOMAIN_NAME" 
    else
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
        )
         RECORD_NAME="$instance.$DOMAIN_NAME" 
    fi

echo "IP address $IP"

 /usr/local/bin/aws route53 change-resource-record-sets \
  --hosted-zone-id $Hosting_ID \
  --change-batch '
    {
        "Comment": "Updating record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '

echo "record updated for $instance"
done