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

 sudo dnf install -y gcc make jemalloc-devel &>> $LOGFILE

VALIDATE $? " Install build Dependies"

wget http://download.redis.io/releases/redis-6.2.13.tar.gz

VALIDATE $? " Download Redis 6.2 Source Code"

tar xzf redis-6.2.13.tar.gz &>> $LOGFILE

VALIDATE $? "untar redis 6.2.13"

cd redis-6.2.13 

VALIDATE $? "changining the directory"

make
sudo make install &>> $LOGFILE

VALIDATE $? "install make"

redis-server-version &>> LOGFILE

VALIDATE $? "redis version"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf 

VALIDATE $? "Changing the localhost"

systemctl enable redis  &>> $LOGFILE
systemctl start redis   &>> $LOGFILE

VALIDATE $? "Enable and start redis"



