#!/bin/bash

# Permissions

# Display the user ID
echo "User ID: $(id -u)"
#DOCKER_PUID=1000

# Display the group ID
echo "Group ID: $(id -g)"
#DOCKER_PGID=1000

# Display the user root ID
echo "User root ID: $(id root -u)"
#DOCKER_ROOTPUID=0

# Display the group ID
echo "Group root ID: $(id root -g)"
#DOCKER_ROOTPGID=0

# Display the users in the group: docker
echo "Group ID: $(grep /etc/group -e "docker")"
#DOCKER_GID=998
