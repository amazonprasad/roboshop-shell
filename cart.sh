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

dnf module disable nodejs -y &>> $LOGFILE   

VALIDATE $? "Disable nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? " Enable Nodejs"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? " Install Node js"

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
    echo -e "$G roboshop user creation $N"
else 
    echo -e " roboshop user already exist $Y SKIPPING $N"
fi 

mkdir -p /app

VALIDATE $? " Creating directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? " Downloading roboshop files"

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? " Uzip the  files "

 npm install  &>> $LOGFILE
  
VALIDATE $? " Instaal npm"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service

VALIDATE $? "Copying file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? " Daemon-reload "

systemctl enable cart 
systemctl start cart

VALIDATE $? " Enable and start cart"

