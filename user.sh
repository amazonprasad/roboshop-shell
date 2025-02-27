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

if [ $USERID - ne 0 ]
then 
    echo -e " $R ERROR: You are not the root user $N"
else 
    echo -e "$G You are the root user $N"
fi 

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disable Nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? " Enable Nodejs"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? " Install Nodejs"

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else 
    echo -e " Roboshop user already exist $Y Skipping $N"

fi 

mkdir -p /app 

VALIDATE $? " Creating directory app"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip &>> $LOGFILE

cd /app 

VALIDATE $? " Changing directory"

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? " Unziping files"

cd /app 
npm install  &>> $LOGFILE

VALIDATE $? "Installing npm"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service 

VALIDATE $? "Copying files"

systemctl daemon-reload 

VALIDATE $? "Daemon reload"

systemctl enable user 
systemctl start user

VALIDATE $? " start user"


cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? " installing mongodb"

mongo --host 172.31.88.75 </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Host mongodb"







