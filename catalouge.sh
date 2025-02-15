#!/bin/bash
DATE=$(date +%F)
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log
IDUSER=$(id -u)
R="\e[31m"
G="\e[32"
N="\e[0m"

SCRIPT_NAME=$0

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2....$R FAILURE $N"
        exit 1
    else 
        echo -e "$2.... $G SUCCESS $N"
    fi 
}

if [ $USERID -ne 0 ]
then 
    echo -e " $R ERROR: Your are not the root user $N"
    exit 1
else 
    echo -e " $G Your are the root user $N"
fi 

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? " Disable nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? " Enable  nodejs"

dnf install nodejs -y  &>> $LOGFILE

VALIDATE $? " Installing nodejs"

useradd roboshop 

VALIDATE $? " Creating user roboshop"

mkdir -p /app 

VALIDATE $? "creating directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? " Downloading files"

cd /app 

VALIDATE $? " Change Directory"

unzip -o /tmp/catalogue.zip &>> $LOGFILE
 
VALIDATE $? "Unzip files"

cd /app 

VALIDATE $? " Change Directory"

npm install   &>> $LOGFILE
 
VALIDATE $? " Install rpm"

cp /home/centos/reboshop-shell/catalouge.service /etc/systemd/system/catalogue.service 

VALIDATE $? "Copying the catalouge service"

systemctl daemon-reload

VALIDATE $? "Daemon reload service"

systemctl enable catalogue 

VALIDATE $? "Enable catalouge"

systemctl start catalogue

VALIDATE $? "Start Catalouge"

cp /home/centos/roboshop-shell/mangodb.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying the mongodb.repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Install mongodb"

mongo --host 172.31.94.235 </app/schema/catalogue.js

VALIDATE $? "Replace the IP Address"








