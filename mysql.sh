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
# dnf list installed mysql-community-server &>> $log_file
# if [ $? -eq 0 ];then
# echo  -e "$Y mysql is already installed $N" | tee -a $log_file
# else
dnf install mysql-server -y &>>$log_file
validate "installed mysql"
# fi
systemctl enable mysqld
systemctl start mysqld  
validate "enabling and starting mysql"

read -s -p "enter MYSQL password" MYSQLPASS
echo
mysql_secure_installation --set-root-pass $MYSQLPASS
# mysql_secure_installation --set-root-pass RoboShop@1
validate "setting rootpassword"