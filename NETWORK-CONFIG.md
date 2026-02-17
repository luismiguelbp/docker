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
| Portainer | 172.16.1.10 | 9000, 9443, 8000 |
| Mosquitto | 172.16.1.11 | 1883, 8883, 9001 |
| Node-RED | 172.16.1.12 | 1880 |
| Grafana | 172.16.1.13 | 3000 |
| PostgreSQL | 172.16.1.14 | 5432 |
| SQLite Web | 172.16.1.15 | 9080 |

## How to Restore Static IPs

If you want to use static IPs, add the following to each service in your compose files:

### Portainer

```yaml
services:
  portainer:
    networks:
      docker-bridge:
        ipv4_address: 172.16.1.10
```

### Mosquitto

```yaml
services:
  mosquitto:
    networks:
      docker-bridge:
        ipv4_address: 172.16.1.11
```

### Node-RED

```yaml
services:
  node-red:
    networks:
      docker-bridge:
        ipv4_address: 172.16.1.12
```

### Grafana

```yaml
services:
  grafana:
    networks:
      docker-bridge:
        ipv4_address: 172.16.1.13
```

### PostgreSQL (if using static IP)

```yaml
services:
  postgresql:
    networks:
      docker-bridge:
        ipv4_address: 172.16.1.14
```

### SQLite Web (if using static IP)

```yaml
services:
  sqlite-web:
    networks:
      docker-bridge:
        ipv4_address: 172.16.1.15
```

## Local Network Details

- **Macvlan Parent Interface:** eth0 (example only)
- **Subnet:** 192.168.1.0/24 (example only)
- **Gateway:** 192.168.1.1 (example only)

## Firewall and Network Security

These examples assume a Linux host using `ufw` as a simple firewall. Adapt the IP ranges, ports, and tools to match your environment.

```bash
# Allow SSH for remote administration
sudo ufw allow 22/tcp

# Allow Grafana only from the local LAN
sudo ufw allow from 192.168.1.0/24 to any port 3000 proto tcp

# Allow MQTT from the local LAN only
sudo ufw allow from 192.168.1.0/24 to any port 1883 proto tcp

# Enable the firewall (review rules first)
sudo ufw enable
```

General recommendations:

- Expose only the ports you actually need from outside the host.
- Prefer limiting access to trusted subnets (for example, your home LAN) instead of allowing the whole internet.
- Combine firewall rules with secure service configuration (for example, Mosquitto authentication and TLS as described in `README.md`).
