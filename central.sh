#!/bin/bash

while getopts n:i:p:e:c:a: flag
do
    case "${flag}" in
        n) NAME_SERVICE=${OPTARG};;
        i) IMAGE_TAG=${OPTARG};;
        p) PORT_SERVICE=${OPTARG};;
        e) ENV=${OPTARG};;
        c) COMMAND=${OPTARG};;
        a) ARCH=${OPTARG};;
    esac
done

SERVICE=$(curl -s --location --request GET 'https://integration-middleware-2.qiscus.com/api/alpha/show_applications?app='$NAME_SERVICE'' --header "Content-Type: application/json" --header "x-secret-signature: "$PROJECT_CENTRAL_TOKEN"")

if [[ -n $IMAGE_TAG ]]
then
    export IMAGE_TAG=$IMAGE_TAG
else
    export IMAGE_TAG=$(echo $SERVICE | yq ".image")
fi

if [[ -n $PORT_SERVICE ]]
then
    export PORT_SERVICE=$PORT_SERVICE
else
    export PORT_SERVICE=$(echo $SERVICE | yq .port)
fi

if [[ -n $ENV ]]
then
    export ENV=$ENV
else
    export ENV=$(echo $SERVICE | yq .env)
fi

if [[ -n $COMMAND ]]
then
    export COMMAND=$COMMAND
else
    export COMMAND=$(echo $SERVICE | yq .command)
fi

if [[ -n $ARCH ]]
then
    export ARCH=$ARCH
else
    export ARCH=$(echo $SERVICE | yq .arch)
fi

curl --silent --location --request PUT "https://integration-middleware-2.qiscus.com/api/alpha/update_applications" \
--header "Content-Type: application/json" --header "x-secret-signature: "$PROJECT_CENTRAL_TOKEN"" \
--data '{ "name": "'"$NAME_SERVICE"'", "image": "'"$IMAGE_TAG"'", "app_label": "'"$NAME_SERVICE"'", "port": '$PORT_SERVICE', "env": "'"$ENV"'", "command": "'"$COMMAND"'", "arch": "'"$ARCH"'"}'
