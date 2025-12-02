#!/bin/bash
wget https://raw.githubusercontent.com/DavidCliff9/PostgresDockerIntegration/refs/heads/main/AWSDockerScript.sh
sudo chmod 777 AWSDockerScript.sh
./AWSDockerScript.sh
docker-compose up
