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


curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? " Configure rabbitmq"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? " rabbitma dependencies"

dnf install rabbitmq-server -y  &>> $LOGFILE

VALIDATE $? " Install rabbitmq"

systemctl enable rabbitmq-server 
systemctl start rabbitmq-server 

VALIDATE $? " enable and start rabbitmq"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE

VALIDATE $? "set permissions"

