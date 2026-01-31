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

# if command -v node &>/dev/null; then
#   echo "Node.js already installed"
# else
#   echo "Installing Node.js"
 
dnf module enable nodejs:20 -y &>>$log_file
validate "enabling nodejs"

dnf install nodejs -y &>>$log_file
validate "installing nodejs"
# fi
id roboshop 
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate "system user adding"
else
echo -e "$Y roboshop user already exists..skipping $N"
fi

mkdir -p /app 
validate "creating directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>>$log_file
validate "downloading cart code"
cd /app 
validate "inside app dictory"
rm -rf /app/* &>>$log_file
validate "removing existing files"

unzip /tmp/cart.zip &>>$log_file
validate "unzip cart code"

npm install &>>$log_file
validate "installing dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
validate "created systemctl service"

systemctl daemon-reload
systemctl enable cart 
systemctl start cart
validate "daemonreload enabling and starting cart"
