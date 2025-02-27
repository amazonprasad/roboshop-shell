#!/bin/bash

DATE=$(date +%F)
SCRIPT_NAME=$0
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log
USERID=$(id -u)
Mysql_Host=mysql.manacars.shop
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){

    if [ $1 -ne 0 ]
    then
        echo -e " $2.... $R FAILURE $N"
    else 
        echo -e "$2.... $G SUCCESS $N"
    fi 
}

if [ $USERID -ne 0 ]
then 
    echo -e " $R ERROR: You are not the root user $N"
else 
    echo -e "$G You are the root user $N"
fi 

dnf install maven -y &>> $LOGFILE

VALIDATE $? " Install maven "

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then 
    useradd roboshop 
    echo -e " $G Roboshop user creation $N"
else 
    echo -e " Roboshop user already exist $Y Skipping $N"
fi 

mkdir -p /app

VALIDATE $? " creating app directory "

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? " Downloading files"

cd /app 
unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? " Unzip files"

cd /app 
mvn clean package &>> $LOGFILE

VALIDATE $? " MVn cleam packages"

mv target/shipping-1.0.jar shipping.jar  &>> $LOGFILE

VALIDATE $? "copy jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service

VALIDATE $? " copying files"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? " daemon-reload shipping"

systemctl enable shipping 
systemctl start shipping

VALIDATE $? " enable and start shipping"

dnf install mysql -y  &>> $LOGFILE
VALIDATE $? " Install mysql"

mysql -h mysql.manacars.shop -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? " loading shipping data"

systemctl restart shipping  &>> $LOGFILE 

VALIDATE $? "restart shipping"





