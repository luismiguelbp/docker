# Example Network Configuration

This file provides example network settings for documentation purposes.
Use it as a template and replace values in your own local configuration.

## Network Settings

### Bridge Network

```yaml
networks:
  docker-bridge:
    name: docker-bridge
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: "172.16.1.0/24"
```

### Macvlan Network

```yaml
networks:
  docker-macvlan:
    name: docker-macvlan
    driver: macvlan
    driver_opts:
      parent: eth0
    ipam:
      config:
        - subnet: "192.168.1.0/24"
          ip_range: "192.168.1.0/32"
          gateway: "192.168.1.1"
```

## Static IP Assignments

| Service | IP Address | Port(s) |
|---------|------------|---------|
| Portainer | 172.16.1.5 | 9000, 9443, 8000 |
| Mosquitto | 172.16.1.10 | 1883, 8883, 9001 |
| Node-RED | 172.16.1.15 | 1880 |
| Grafana | 172.16.1.20 | 3000 |
| PostgreSQL | 172.16.1.25 | 5432 |

## How to Restore Static IPs

If you want to use static IPs, add the following to each service in your compose files:

### Portainer

```yaml
services:
  portainer:
    networks:
      docker-bridge:
        ipv4_address: 172.16.1.5
```

### Mosquitto

```yaml
services:
  mosquitto:
    networks:
      docker-bridge:
        ipv4_address: 172.16.1.10
```

### Node-RED

```yaml
services:
  node-red:
    networks:
      docker-bridge:
        ipv4_address: 172.16.1.15
```

### Grafana

```yaml
services:
  grafana:
    networks:
      docker-bridge:
        ipv4_address: 172.16.1.20
```

### PostgreSQL (if using static IP)

```yaml
services:
  postgresql:
    networks:
      docker-bridge:
        ipv4_address: 172.16.1.25
```

## Local Network Details

- **Macvlan Parent Interface:** eth0 (example only)
- **Subnet:** 192.168.1.0/24 (example only)
- **Gateway:** 192.168.1.1 (example only)
