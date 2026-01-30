#!/bin/bash
Userid=$(id -u)

R='\e[31m'
G='\e[32m'
Y='\e[33m'
B='\e[34m'
N='\e[0m'   # No Color

log_folder="/var/log/roboshop"
log_file="$log_folder/$0.log"
if [ $Userid -ne 0 ]; then
echo -e "$R this is not sudo user $N" | tee -a $log_file
exit 1
fi
mkdir -p $log_folder
# Package=$1
validate (){
    if [ $? -eq 0 ]; then 
echo -e "$1.. $G Success $N" | tee -a $log_file
else 
echo -e "$1.. $R failure $N" | tee -a $log_file
fi
}
cp mongo.repo /etc/yum.repos.d/mongo.repo
validate "copying mongo repo"

dnf install mongodb-org -y &>>$log_file
validate "Installing Mongodb server"

systemctl enable mongod 
validate "enabling mongodb"
systemctl start mongod 
validate "starting mongodb"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
validate "allowing remote connections"

systemctl restart mongod
validate "restarted mongodb"