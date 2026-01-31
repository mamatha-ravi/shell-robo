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

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
dnf list installed rabbitmq-server &>> $log_file
if [ $? -eq 0 ];then
echo  -e "$Y rabbitmq is already installed $N" | tee -a $log_file
else
dnf install rabbitmq-server -y &>> $log_file
validate "installing rabbitmq"
fi
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
validate "enabling and starting rabbitmq"

rabbitmqctl list_users | grep -w roboshop &>> "$log_file"
if [ $? -ne 0 ]; then
  rabbitmqctl add_user roboshop roboshop123 &>> "$log_file"
  validate "rabbitmq user adding"
else
  echo -e "$Y rabbitmq user already exists $N" | tee -a "$log_file"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validate "default user permissions"
