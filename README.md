# home-automation-docker

Home Automation using Docker and deploy confgurations using docker-compose.

Docker services:

* [Portainer](https://github.com/portainer) - container management made easy.
* [Mosquitto](https://github.com/eclipse/mosquitto) - is an open source implementation of MQTT server.
* [Node-Red](https://github.com/node-red/node-red) - low-code programming for event-driven applications.
* [InfluxDB](https://github.com/influxdata/influxdb) - time series database
* [Grafana](https://github.com/grafana/grafana) - visualization UI for InfluxDB

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

| Host Port | Service |
| - | - |
| 9000 | Portainer |
| 1883, 9001 | Mosquitto |
| 1880 | Node-Red |
| 3000 | Grafana |
| 8086 | InfluxDB |

## Pending topics

## Pending services

- mysql
- phpmyadmin
- redis
