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
        echo -e " $2... $R FAILURE $N"
        exit 1 
    else 
        echo -e " $2... $G SUCCESS $N"
    fi
 }

if [ $USERID -ne 0 ]
then 
    echo -e " $R ERROR: Your are not the root user $N"
    exit 1
else 
    echo -e " $G YOur are the root user $N"
fi 

dnf install nginx -y &>>$LOGFILE

VALIDATE $? "Installing nginx"

systemctl enable nginx  &>>$LOGFILE

VALIDATE $? "enable nginx"

systemctl start nginx  &>>$LOGFILE

VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/*  &>>$LOGFILE

VALIDATE $? "removing htmml directory"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip  &>>$LOGFILE

VALIDATE $? "downloading the fronted files"

cd /usr/share/nginx/html  

unzip -o /tmp/frontend.zip &>>$LOGFILE

VALIDATE $? "uzip the files"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$LOGFILE

VALIDATE $? " Copying the files" 

systemctl restart nginx  &>>$LOGFILE

VALIDATE $? "restart nginx"


