#!/bin/bash
wget https://raw.githubusercontent.com/Medical-Record-System/Postgres-Docker/main/AWSDockerInstall.sh
sudo chmod 777 AWSDockerScript.sh
./AWSDockerScript.sh
docker-compose up
