#!/bin/bash

OWNER="ahmedmohsen5"
REPO="End-To-End-GoLang"

AWS_ACCESS_KEY=$(awk -F "=" '/AWS_ACCESS_KEY_ID/ {print $2}' ~/.aws/credentials | xargs)
AWS_SECRET_ACCESS_KEY=$(awk -F "=" '/AWS_SECRET_ACCESS_KEY/ {print $2}' ~/.aws/credentials | xargs)



create_secret(){
    local secret_name=$1
    local secret_password=$2

    echo "setting scret $secret_name ....."
    echo $secret_password | gh secret set $secret_name --repo $OWNER/$REPO
    if [ $? -eq 0 ]; then
        echo "The $secret_name is correct"
    else
        echo "the $secret_name is faild."
        exit 1
    fi   
}
create_secret "AWS_ACCESS_KEY_ID" "$AWS_ACCESS_KEY_ID"
create_secret "AWS_SECRET_ACCESS_KEY" "$AWS_SECRET_ACCESS_KEY"
echo "$AWS_ACCESS_KEY"
echo "$AWS_SECRET_ACCESS_KEY"
echo "the end"

