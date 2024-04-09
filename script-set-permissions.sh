#!/bin/bash

# Permissions

DIRECTORY="/docker"

# Set folder and files owner
FOLDER="$DIRECTORY"
[ -d "$FOLDER" ] && sudo chown -R root:docker "$FOLDER" || echo "$FOLDER does not exists."

# portainer
FOLDER="$DIRECTORY/portainer"
[ -d "$FOLDER" ] && sudo chmod -R 750 "$FOLDER" || echo "$FOLDER does not exists."

# mosquitto
FOLDER="$DIRECTORY/mosquitto"
[ -d "$FOLDER" ] && sudo chmod -R 750 "$FOLDER" || echo "$FOLDER does not exists."
FILE="$DIRECTORY/mosquitto/config/mosquitto.conf"
[ -f "$FILE" ] && sudo chmod 640 "$FILE" || echo "$FILE does not exists."
FILE="$DIRECTORY/mosquitto/config/passwords_file"
[ -f "$FILE" ] && sudo chmod 640 "$FILE" || echo "$FILE does not exists."
FILE="$DIRECTORY/mosquitto/data/mosquitto.db"
[ -f "$FILE" ] && sudo chmod 0700 "$FILE" || echo "$FILE does not exists."

# node-red
FOLDER="$DIRECTORY/node-red"
[ -d "$FOLDER" ] && sudo chmod -R 750 "$FOLDER" || echo "$FOLDER does not exists."

# grafana
FOLDER="$DIRECTORY/grafana"
[ -d "$FOLDER" ] && sudo chmod -R 750 "$FOLDER" || echo "$FOLDER does not exists."

# influxdb
FOLDER="$DIRECTORY/influxdb"
[ -d "$FOLDER" ] && sudo chmod -R 750 "$FOLDER" || echo "$FOLDER does not exists."
