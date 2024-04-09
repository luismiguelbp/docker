#!/bin/bash

DIRECTORY="/docker"

# portainer
FOLDER="$DIRECTORY/portainer/data"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"
FOLDER="$DIRECTORY/portainer/certs"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"

# mosquitto
FOLDER="$DIRECTORY/mosquitto/config"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"
FOLDER="$DIRECTORY/mosquitto/data"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"
FOLDER="$DIRECTORY/mosquitto/log"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"
FILE="$DIRECTORY/mosquitto/config/mosquitto.conf"
[ -f "$FILE" ] && echo "$FILE exists." || touch "$FILE"
FILE="$DIRECTORY/mosquitto/config/passwords_file"
[ -f "$FILE" ] && echo "$FILE exists." || touch "$FILE"

# node-red
FOLDER="$DIRECTORY/node-red/data/lib"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"
FOLDER="$DIRECTORY/node-red/data/logs"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"
FOLDER="$DIRECTORY/node-red/data/node_modules"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"

# grafana
FOLDER="$DIRECTORY/grafana/data"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"
FOLDER="$DIRECTORY/grafana/provisioning/datasources"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"
FOLDER="$DIRECTORY/grafana/provisioning/plugins"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"
FOLDER="$DIRECTORY/grafana/provisioning/notifiers"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"
FOLDER="$DIRECTORY/grafana/provisioning/alerting"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"
FOLDER="$DIRECTORY/grafana/provisioning/dashboards"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"

# influxdb
FOLDER="$DIRECTORY/influxdb/data"
[ -d "$FOLDER" ] && echo "$FOLDER already exists." || mkdir -p "$FOLDER"

# docker enviroment file
FILE="$DIRECTORY/.env"
[ -f "$FILE" ] && echo "$FILE exists." || cp "$DIRECTORY"/.env-default "$FILE"
