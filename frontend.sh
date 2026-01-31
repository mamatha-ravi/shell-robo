#!/bin/bash
Userid=$(id -u)
SCRIPT_DIR=$PWD
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
# dnf list installed nginx &>> $log_file
# if [ $? -eq 0 ];then
# echo  -e "$Y nginx is already installed $N" | tee -a $log_file
# else
 dnf module disable nginx -y
dnf module enable nginx:1.24 -y &>> $log_file
validate "enabling nginx"
dnf install nginx -y &>> $log_file
validate "installing nginx"
# fi
systemctl enable nginx 
validate "enabling systemctl nginx"
systemctl start nginx 
validate "starting systemctl nginx"
rm -rf /usr/share/nginx/html/* 
validate "removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $log_file
validate "downloading frontend content"

cd /usr/share/nginx/html 
validate "change dir to nginx html"
unzip /tmp/frontend.zip &>> $log_file
validate "unzip frontend content"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
validate "nginx reverse proxy"

systemctl restart nginx 
validate "restarting nginx"

