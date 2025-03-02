#!/bin/bash
# set -x
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf install nginx -y  &>>LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>LOGFILE
VALIDATE $? "Enable nginx"

systemctl start nginx &>>LOGFILE
VALIDATE $? "Start nginx"

rm -rf /usr/share/nginx/html/* &>>LOGFILE
VALIDATE $? "Removing html nginx"

curl -o /tmp/frontend.zip https://expense-artifacts.s3.amazonaws.com/expense-frontend-v2.zip &>>LOGFILE
VALIDATE $? "Downloading nginx"

cd /usr/share/nginx/html &>>LOGFILE
unzip -o /tmp/frontend.zip &>>LOGFILE
VALIDATE $? "Extracting frontend application"

cp /root/expense-project-shell/expense.conf /etc/nginx/default.d/expense.conf &>>LOGFILE
VALIDATE $? "Coping expense application"

systemctl restart nginx &>>LOGFILE
VALIDATE $? "Restarting nginx"