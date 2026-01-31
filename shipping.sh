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

dnf list installed maven &>> "$log_file"
if [ $? -eq 0 ]; then
  echo -e "$Y maven is already installed $N" | tee -a "$log_file"
else
  echo -e "$G installing maven $N" | tee -a "$log_file"

  dnf install maven -y &>> "$log_file"
  validate "install maven"
  fi
id roboshop 
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate "system user adding"
else
echo -e "$Y roboshop user already exists..skipping $N"
fi

mkdir -p /app 
  validate "creating directory"\

  curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$log_file
cd /app 
unzip /tmp/shipping.zip &>>$log_file

mvn clean package &>>$log_file
mv target/shipping-1.0.jar shipping.jar &>>$log_file
validate "download dependencies"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
validate "systemctl"

systemctl daemon-reload
validate "daemon"

systemctl enable shipping 
systemctl start shipping
validate "enabling and starting shipping"


dnf install mysql -y &>>$log_file
validate "install sql"


mysql -h mysql.devops88s.online -uroot -pRoboShop@1 < /app/db/schema.sql
validate "schema"

mysql -h mysql.devops88s.online -uroot -pRoboShop@1 < /app/db/app-user.sql 
validate "user"

mysql -h mysql.devops88s.online -uroot -pRoboShop@1 < /app/db/master-data.sql
validate "data"

systemctl restart shipping
validate "restarting shipping"