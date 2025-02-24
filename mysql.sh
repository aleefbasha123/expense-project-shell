#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VLAIDATE (){
    if [ $1 -ne 0 ]
    then
         echo -e "$2....$R FAILURE $N"
    else
         echo -e "$2....$G Success $N"
    fi
}

if [ $USERID -ne 0 ]
then
     echo "Please run the script with root user"
     exit 1 # manually exit if error comes"
else
     echo "You are super user"
fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing Mysql server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "enabeling Mysql server"

systemctl start mysqld &>>LOGFILE
VALIDATE $? "starting mysql server"

mysql_secure_insatllation --set-root-pass ExpenseApp@1 &>>LOGFILE
VALIDATE $? "setting up root password"

