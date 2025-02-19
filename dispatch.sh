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


dnf install golang -y &>> $LOGFILE

VALIDATE $? "Install goland"

id=roboshop 
if [ $? -ne 0 ]
then 
    useradd roboshop 
    echo -e " $G roboshop user creation $N"
else
    echo -e " already roboshop user exist $Y Skipping $N"
fi

mkdir -p /app

VALIDATE $? " creating directories"

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip  &>> $LOGFILE

VALIDATE $? " downloading files"

cd /app 
unzip /tmp/dispatch.zip &>> $LOGFILE

VALIDATE $? " unzip files"

cd /app 
go mod init dispatch &>> $LOGFILE
VALIDATE $? " go mod init dispatch"

go get &>> $LOGFILE

VALIDATE $? " go get"


go build  &>> $LOGFILE

VALIDATE $? "go build"

cp /home/centos/roboshop-shell/dipatch.service /etc/systemd/system/dispatch.service 

VALIDATE $? " copying files"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon-reload"

systemctl enable dispatch 
systemctl start dispatch 


VALIDATE $? "Enable and start dispatch"



