#!/bin/bash

DATE=$(date +%F)
SCRIPT_NAME=$0
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log
USERID=$(id -u)
Mongodb_Host=mongodb.manacars.shop
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


dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? " Install python"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then 
    useradd roboshop
    echo -e "$G Roboshop user creation $N"
else 
    echo -e " Roboshop user already exist $Y SKIPPING $N"

fi 

mkdir -p /app

VALIDATE $? " creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? " Downloading files"

cd /app 

unzip -o /tmp/payment.zip &>> $LOGFILE

VALIDATE $? " unzip files"

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? " Install require "

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service

VALIDATE $? "Copying files"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload payment"

systemctl enable payment &>> $LOGFILE
systemctl start payment 

VALIDATE $? "enable and start payment"


