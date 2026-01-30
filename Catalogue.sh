#!/bin/bash
Userid=$(id -u)
SCRIPT_DIR=$PWD
mongodb_host="mongodb.devops88sonline.com"

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
dnf module disable nodejs -y &>>$log_file
validate "disabling nodejs"

dnf module enable nodejs:20 -y &>>$log_file
validate "enabling nodejs"

dnf install nodejs -y &>>$log_file
validate "installing nodejs"

id roboshop &>>$log_file
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate "system user adding"
else
echo -e "$Y roboshop user already exists..skipping $N"

mkdir -p /app 
validate "creating directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$log_file
validate "downloading catalogue code"
cd /app 
validate "inside app dictory"
rm -rf /app/*
validate "removing existing files"

unzip /tmp/catalogue.zip
validate "unzip catalogue code"

npm install &>>$log_file
validate "installing dependencies"

cp $SCRIPT_DIR/Catalogue.service /etc/systemd/system/catalogue.service
validate "created systemctl service"

systemctl daemon-reload

systemctl enable catalogue 
systemctl start catalogue
validate "starting and enabling catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
validate "copied mongo repo"

dnf install mongodb-mongosh -y &>>$log_file
validate "installing mongodb"

INDEX=$(mongosh --host $mongodb_host --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -le 0 ]; then
    mongosh --host $mongodb_host </app/db/master-data.js
    VALIDATE $? "Loading products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE  "Restarting catalogue"