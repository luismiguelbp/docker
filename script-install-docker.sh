#!/bin/bash

# Install using the apt repository 
# https://docs.docker.com/engine/install/debian/#install-using-the-repository

echo "Install docker using the apt repository..."

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

# Install the Docker packages

echo "Install the docker packages..."

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable docker service

echo "Start docker service..."

#sudo service docker start
sudo systemctl start docker.service
sudo docker run hello-world

echo "Enable docker service..."

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Configure groups and users

#echo "Grant users using docker..."
#sudo groupadd docker
#sudo usermod -aG docker user
