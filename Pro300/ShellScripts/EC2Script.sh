#!/bin/bash
wget https://raw.githubusercontent.com/Medical-Record-System/Postgres-Docker/refs/heads/main/AWSDockerInstall.sh?token=GHSAT0AAAAAADOKMJKYUUO3XUMIV5FIFHEA2JHCG2Q
sudo chmod 777 AWSDockerScript.sh
./AWSDockerScript.sh
docker-compose up
