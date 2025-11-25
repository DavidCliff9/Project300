#!/bin/bash
# This is a script that allows the automatic update of the Medical Suite Database, with deletion script for testing purposes

# Install applications needed to launch the docker file
sudo yum install -y git
sudo yum install -y docker
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "Installed various packages" >> ~/ShellScriptLog.log

# Clone the latest build
git clone https://github.com/DavidCliff9/PostgresDockerIntegration

# Start the Docker version
sudo systemctl start docker
sudo systemctl enable docker
echo "Docker Initalized" >> ~/ShellScriptLog.log

cd PostgresDockerIntegration

# Retrieve the aws secrets into a variable, parse the secret json by name and export as an enviornmental variable
SECRET=$(aws secretsmanager get-secret-value --secret-id proto/docker/manager --query SecretString --output text)

export MEDADMIN_PASS=$(echo $SECRET | jq -r '.medadmin')
export USERAPPLICATION_PASS=$(echo $SECRET | jq -r '.userapplication')
export GPAPPLICATION_PASS=$(echo $SECRET | jq -r '.gpapplication')

# Use the sql.template to inject the enviornmental variables into the create users script
envsubst < init/01declareusers.sql.template > init/01declareusers.sql
echo "Secrets Loaded" >> ~/ShellScriptLog.log

# Give the ec2 permissions to run the docker file
sudo usermod -a -G docker ec2-user
newgrp docker

# Start the database
sudo docker-compose up -d
echo "Docker Setup. Log in via sudo docker exec -it pg psql -U medadmin -d medicalsuite" >> ~/ShellScriptLog.log