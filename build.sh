#!/bin/bash


echo "GENERATE .env" && {
    echo "LOCAL_UID=$(id -u ${USER})"
    echo "LOCAL_GID=$(id -g ${USER})"
    echo "LOCAL_USER=$(whoami)"
} | tee .env

docker compose up -d --build
docker compose run dev

