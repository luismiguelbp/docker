# home-automation-docker

Home Automation using Docker and deploy confgurations using docker-compose.

Docker services:

* [Portainer](/portainer/README.md) - container management made easy.
* [Mosquitto](/mosquitto/README.md) - is an open source implementation of MQTT server.
* [Node-Red](/node-red/README.md) - low-code programming for event-driven applications.
* [Grafana](/grafana/README.md) - visualization UI for databases.
* [InfluxDB](/influxdb/README.md) - time series database.

## Quick Start

To start the app:

```
docker-compose up -d
```

To stop the app:

1. Run the following command from the root of the cloned repo:
```
docker-compose down
```

## Ports

The services in the app run on the following ports:

| HTTP | HTTPS | Service |
| - | - | - |
| 9000, 8000 | 9443 | Portainer |
| 1883, 8883, 9001 | | Mosquitto |
| 1880 | | Node-Red |
| 3000 | | Grafana |
| 8086 | | InfluxDB |

## Pending topics

## Pending services

- mysql
- phpmyadmin
- redis

## Useful docker commands

```
# Clear all containers, images, volumes, networks.
sudo docker system prune -a --force 

# Connect to container shell.
sudo docker exec -it container_name sh
```

## Useful console applications in Linux

```
apt update
apt upgrade -y
apt install nano mc htop curl wget git sudo -y
dpkg-reconfigure tzdata 
dpkg-reconfigure locales 
```
