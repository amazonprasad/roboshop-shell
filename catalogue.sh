#!/bin/bash
DATE=$(date +%F)
SCRIPT_NAME=$0
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log
IDUSER=$(id -u)
Mongodb_Host=mongodb.manacars.shop
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"



VALIDATE(){
    if [ $1 -ne 0 ];
    then 
        echo -e "$2....$R FAILURE $N"
        exit 1
    else 
        echo -e "$2....$G SUCCESS $N"
    fi 
}

if [ $IDUSER -ne 0 ];
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

id roboshop &>> $LOGFILE  #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi


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

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service 

VALIDATE $? "Copying the catalouge service"

systemctl daemon-reload

VALIDATE $? "Daemon reload service"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enable catalouge"

systemctl start catalogue  

VALIDATE $? "Start Catalouge"

cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying the mongodb.repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Install mongodb"

mongo --host $Mongodb_Host </app/schema/catalogue.js  &>> $LOGFILE

VALIDATE $? "Replace the IP Address"









