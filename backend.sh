#!/bin/bash

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

dnf module disable nodejs -y &>>LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>LOGFILE
VALIDATE $? "Enabeling nodejs version 20"

dnf install nodejs -y &>>LOGFILE
VALIDATE $? "Insatalling nodejs"

#useradd expense &>>LOGFILE
#VALIDATE $? "Adding expense user"

id expense  &>>LOGFILE
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "Creating Expense user"
else
     echo -e "Expense user alrady Crated...$Y SKIPPING $N"
fi

mkdir -p /app  -y &>>LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/expense-backend-v2.zip  -y &>>LOGFILE
VALIDATE $? "Downloading the code"
cd /app 

unzip /tmp/backend.zip -y &>>LOGFILE
VALIDATE $? "Unzipping the application"

cd /app 
npm install -y &>>LOGFILE
VALIDATE $? "Insatlling Dependences"

systemctl daemon-reload -y &>>LOGFILE
VALIDATE $? "Reloading deamon"

systemctl enable backend -y &>>LOGFILE
VALIDATE $? "Enabeling backend applcaition"

systemctl start backend -y &>>LOGFILE
VALIDATE $? "Starting application"

dnf install mysql -y -y &>>LOGFILE
VALIDATE $? "Insatlling mysql"

mysql -h 172.31.45.4 -uroot -pExpenseApp@1 < /app/schema/backend.sql -y &>>LOGFILE
VALIDATE $? "Loading schema file" 