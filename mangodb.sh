#!/bin/bash
 DATE=$(date +%F)
 USERID=$(id -u)
 R="\e[31m"
 G="\e[32m"
 N="\e[0m"
 LOGFILE=/tmp/$0.log
 VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e " $2 .. $R FAILURE $N"
        exit 1 
    else 
        echo -e " $2 .. $G SUCCESS $N"
    fi
 }

if [ $USERID -ne 0 ]
then 
    echo -e " $R ERROR: Your are not the root user $N"
    exit 1
else 
    echo -e " $G YOur are the root user $N"
fi 

cp mangodb.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copying mangodb.repo"

dnf install mongodb-org -y &>>LOGFILE

VALIDATE $? "Install mangodb"

systemctl enable mongod &>>LOGFILE

VALIDATE $? "enable mangodb"

systemctl start mongod &>>LOGFILE

VALIDATE $? "start mangodb"

sed -i 's/127.0.0.0/0.0.0.0/g' /etc/mongod.conf &>>LOGFILE

VALIDATE $? "remote access to mangodb"

systemctl restart mongod  &>>LOGFILE


VALIDATE $? "restart mangodb"

