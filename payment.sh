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


if rpm -q python3 &>/dev/null; then
  echo -e "$Y python3 already installed $N"
else
  dnf install python3 gcc python3-devel -y &>>$log_file
  validate "install python3"
fi


 id roboshop 
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate "system user adding"
else
echo -e "$Y roboshop user already exists..skipping $N"
fi

mkdir -p /app 
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$log_file
cd /app 
unzip /tmp/payment.zip
validate "unzip"

pip3 install -r requirements.txt &>>$log_file
validate "dependencies install"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
validate "systemctl"

systemctl daemon-reload
validate "daemon"

systemctl enable payment 
systemctl start payment
validate "enable and start"












