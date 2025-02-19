#!/bin/bash
SCRIPT_NAME=$0
DATE=$(date +%F)
USERID=$(id -u)
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILURE $N"
    else 
        echo -e "$2... $G SUCCESS $N"
    fi 
}

if [ $USERID -ne 0 ]
then 
    echo -e " $R ERROR: your are not the root user $N"
else 
    echo -e " $G You are the root user $N"
fi

dnf install redis -y &>> LOGFILE

VALIDATE $? " Installing redis"

redis-server-version &>> LOGFILE

VALIDATE $? "redis version" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf 

VALIDATE $? "Changing the localhost"

systemctl enable redis  &>> $LOGFILE
systemctl start redis   &>> $LOGFILE

VALIDATE $? "Enable and start redis"





