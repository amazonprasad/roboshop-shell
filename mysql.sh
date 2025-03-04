#!/bin/bash


DATE=$(date +%F)
USERID=$(id -u)
SCRIPT_NAME=$0
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2.... $R FAILURE $N"
    else 
        echo -e " $2.... $G SUCCESS $N"
    fi 
}

if [ $? -ne 0 ]
then 
    echo -e " $R ERROR: You are not the root user $N"
else 
    echo -e " $G you are the root user  $N"
fi


dnf module disable mysql -y  &>> $LOGFILE

VALIDATE $? " Disable mysql "

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo

VALIDATE $? " Copying files"

dnf install mysql-community-server -y  &>> $LOGFILE

VALIDATE $? "Install mysql"

systemctl enable mysqld &>> $LOGFILE
systemctl start mysqld  

VALIDATE $? "enable and start mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? " Set mysql password"

