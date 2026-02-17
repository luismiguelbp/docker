# Docker Home Automation Stack

Home automation using Docker, with deployments managed by Docker Compose.

## Available Services

| Service | Description | Port |
|---------|-------------|------|
| **Portainer** | Container management UI | 8000, 9000, 9443 |
| **Mosquitto** | MQTT broker for IoT | 1883, 8883, 9001 |
| **Node-RED** | Low-code programming for event-driven applications | 1880 |
| **Grafana** | Visualization dashboards | 3000 |
| **PostgreSQL** | Relational database | 5432 |
| **SQLite Web** | SQLite database management UI | 9080 |

## Requirements

- A Linux host with **Docker Engine** and the **Docker Compose plugin** available as `docker compose`.
- Basic CLI tools such as `git`, `sudo`, and a shell.

On a completely fresh **Debian/Ubuntu** server, the chronological setup is:

1. Prepare the system and install Docker using the commands in **Initial System Setup (Debian/Ubuntu)** at the end of this document (which internally uses `./scripts/docker-setup.sh install`).
2. Then follow the steps in **Quick Start** below to clone this repository, create data folders, configure `.env`, and start the services.

## Quick Start

### 1. Clone and Configure

```bash
# Clone the repository
git clone https://github.com/luismiguelbp/docker.git /opt/docker
cd /opt/docker

# Ensure scripts are executable
chmod +x scripts/*.sh
```

### Install Docker (if needed)

If Docker Engine and the `docker compose` plugin are **not** already installed on this host:

- **Debian/Ubuntu**: use the helper script (wraps the official Docker APT repository):

  ```bash
  sudo ./scripts/docker-setup.sh install
  ```

- **Other Linux distributions**: install Docker Engine and the `docker compose` plugin using the official Docker documentation, then continue with the steps below.

### 2. Create Folders and Set Permissions

```bash
# Create required directories and set permissions
sudo ./scripts/docker-setup.sh init /opt/docker

# Or run steps individually
sudo ./scripts/docker-setup.sh create /opt/docker
sudo ./scripts/docker-setup.sh perms /opt/docker
```

After running `init` (or `create`), the script will create `/opt/docker/.env` from `.env.example` if it does not already exist. **Edit this file before starting any services:**

```bash
nano /opt/docker/.env
```

### 3. Copy Required Configuration Files

```bash
# Mosquitto requires a config file (Mosquitto 2.x won't start without it)
cp templates/mosquitto/config/mosquitto.conf /opt/docker/data/mosquitto/config/
```

### 4. Start Services

```bash
# Start all configured services
docker compose up -d

# View logs
docker compose logs -f

# Check status
docker compose ps
```

### 5. Stop Services

```bash
docker compose down
```

## Configuration

### Environment Variables

Edit `.env` to customize:

- `COMPOSE_FILE`: Select which services to run
- `DOCKER_PATH`: Data directory (default: `/opt/docker`)
- `DOCKER_TZ`: Your timezone
- Service-specific credentials (PostgreSQL, Grafana, Node-RED)

### PostgreSQL Data Path Note

This stack uses `postgres:16-alpine`, which stores data in `/var/lib/postgresql/data` inside the container. If you move to PostgreSQL 18+ later, the official image changes the default data directory to a versioned path (for example, `/var/lib/postgresql/18/docker`). Update the volume mapping accordingly when upgrading.

### Node-RED Credential Secret

Node-RED encrypts flow credentials (passwords, API keys) using a secret key. Generate a secure secret and add it to your `.env` file:

```bash
# Generate a secure secret
openssl rand -hex 32

# Add to .env
NODE_RED_CREDENTIAL_SECRET=your-generated-secret-here
```

Without this, Node-RED uses a system-generated key that will be lost if the container is recreated, making your credentials unrecoverable.

The `NODE_RED_CREDENTIAL_SECRET` environment variable is passed to the container, which configures `credentialSecret` in Node-RED's settings. See the official documentation for more details: [Running Node-RED under Docker](https://nodered.org/docs/getting-started/docker).

### Selecting Services

Edit the `COMPOSE_FILE` variable in `.env`:

```bash
# Minimal setup (just Portainer)
COMPOSE_FILE=compose.yml,compose-portainer.yml

# Full IoT stack
COMPOSE_FILE=compose.yml,compose-portainer.yml,compose-mosquitto.yml,compose-node-red.yml,compose-grafana.yml,compose-postgresql.yml
```

### Health Checks

Several services include Docker health checks so that `depends_on` can wait for them to be ready:

- **Mosquitto**: Uses `mosquitto_sub` against the `$SYS` topic to verify the broker is responding before dependents start.
- **Node-RED**: Periodically checks `http://localhost:1880/` inside the container.
- **PostgreSQL**: Uses `pg_isready` to verify the database is accepting connections.
- **Grafana**: Calls the `/api/health` HTTP endpoint.
- **SQLite Web**: Uses an HTTP check against `http://localhost:8080/`.
- **Portainer**: Does not expose a standard Docker health check; the official image uses a minimal base without common tools.

When a service uses `depends_on` with `condition: service_healthy`, Docker Compose waits until the upstream service is marked **healthy** before starting the dependent container (for example, Node-RED waiting for Mosquitto, or Grafana waiting for PostgreSQL).

## Directory Structure

```
/opt/docker/
├── .env                 # Environment configuration
├── compose.yml          # Base network configuration
├── compose-*.yml        # Service definitions
├── NETWORK-CONFIG.md    # Network config documentation
├── templates/           # Configuration templates (copy manually)
│   └── mosquitto/config/mosquitto.conf
└── data/                # Persistent service data (ignored by git)
    ├── grafana/
    ├── mosquitto/
    ├── node-red/
    ├── portainer/
    ├── postgresql/
    └── sqlite/
```

## Configuration Templates

The `templates/` folder contains configuration files that need to be copied to `data/` before starting services.

| Template | Destination | Required |
|----------|-------------|----------|
| `templates/mosquitto/config/mosquitto.conf` | `data/mosquitto/config/mosquitto.conf` | Yes (Mosquitto 2.x) |

Copy templates manually:

```bash
cp templates/mosquitto/config/mosquitto.conf ${DOCKER_PATH}/data/mosquitto/config/
```

To customize after setup, edit files in `data/` and restart the service:

```bash
nano ${DOCKER_PATH}/data/mosquitto/config/mosquitto.conf
docker compose restart mosquitto
```

### Mosquitto Security and TLS

Mosquitto can be run in different security modes, depending on your environment:

- **Development / local testing**: `allow_anonymous true` (default template), no authentication.
- **Authenticated (no TLS)**: Disable anonymous access and use a password file.
- **Authenticated with TLS**: Use both a password file and TLS certificates so clients connect securely.

For a more secure setup, start from the secure template in `templates/mosquitto/config/mosquitto.conf.secure` and:

- Disable anonymous access.
- Use a password file.
- Enable a TLS listener with your certificates mounted into the container.

Example snippet for TLS on port 8883:

```conf
listener 8883 0.0.0.0
cafile /mosquitto/ca_certificates/ca.crt
certfile /mosquitto/ca_certificates/mosquitto.crt
keyfile /mosquitto/ca_certificates/mosquitto.key
allow_anonymous false
password_file /mosquitto/config/passwords_file
```

You can mount certificates by mapping a host directory (for example, `${DOCKER_PATH}/data/mosquitto/certs`) to `/mosquitto/ca_certificates` in your Compose configuration or override file. For any broker that is reachable from outside your trusted LAN, you should:

- Switch to the secure template.
- Disable `allow_anonymous`.
- Use a password file and (ideally) TLS.

Example volume mount snippet for `compose-mosquitto.yml`:

```yaml
services:
  mosquitto:
    volumes:
      - ${DOCKER_PATH}/data/mosquitto/config:/mosquitto/config:rw
      - ${DOCKER_PATH}/data/mosquitto/data:/mosquitto/data:rw
      - ${DOCKER_PATH}/data/mosquitto/log:/mosquitto/log:rw
      - ${DOCKER_PATH}/data/mosquitto/certs:/mosquitto/ca_certificates:ro
```

## Backup and Restore

### 1. Backup Data
To create a compressed backup of your entire data directory:

```bash
# Backup to default location (/tmp/docker-backups)
./scripts/docker-backup.sh

# Backup to a specific location
./scripts/docker-backup.sh /path/to/your/backups
```

The script will create a file named `docker_backup_YYYYMMDD_HHMMSS.tar.gz`.

### 2. Restore Data
To restore from a backup:

```bash
# 1. Stop all services
docker compose down

# 2. Extract the backup (replace with your file name)
sudo tar -xzf docker_backup_20260119_120000.tar.gz -C /opt

# 3. Fix permissions (highly recommended)
sudo ./scripts/docker-setup.sh perms
```

## Useful Commands

```bash
# View running containers
docker compose ps

# View logs for a specific service
docker compose logs -f mosquitto

# Restart a service
docker compose restart grafana

# Update all images
docker compose pull && docker compose up -d

# Clean up unused resources
docker system prune -a --force

# Connect to container shell
docker exec -it container_name sh
```

### Health and Status

```bash
# View containers and their status (including health where available)
docker ps --format 'table {{.Names}}\t{{.Status}}'

# View health status for a specific container (example: PostgreSQL)
docker inspect --format='{{json .State.Health}}' ${COMPOSE_PROJECT_NAME}_postgresql

# Show health information in the compose context
docker compose ps
```

## Restart Policies

Each service uses `restart: unless-stopped` in the Compose files. This means:

- Containers are automatically restarted if they exit unexpectedly or after a host reboot.
- If you explicitly stop a container with `docker stop`, Docker does not immediately restart it until you start it again.

Other restart policies exist (such as `no`, `on-failure`, or `always`), but `unless-stopped` provides a good balance for home automation: services recover from failures and reboots while still respecting an intentional manual stop. Keep this in mind when doing maintenance or restoring data (for example, after running the backup/restore steps above).

## Initial System Setup (Debian/Ubuntu)

The `./scripts/docker-setup.sh install` helper supports **Debian/Ubuntu only**. On other Linux distributions, install Docker Engine and the `docker compose` plugin using the official Docker documentation, then follow the **Quick Start** steps above.

```bash
# Update system
apt update && apt upgrade -y

# Install useful tools
apt install nano mc htop curl wget git sudo -y

# Configure timezone and locale
dpkg-reconfigure tzdata
dpkg-reconfigure locales

# Install Docker (Debian/Ubuntu)
./scripts/docker-setup.sh install
```

## Full Setup on a Fresh Debian/Ubuntu Server

For a completely new server, you can run these steps in order:

```bash
# 1) Base system packages
sudo apt update
sudo apt upgrade -y
sudo apt install nano mc htop curl wget git sudo -y

# 2) Optional: configure timezone and locale
sudo dpkg-reconfigure tzdata
sudo dpkg-reconfigure locales

# 3) Clone this repository
sudo mkdir -p /opt
sudo chown "$(id -u)":"$(id -g)" /opt
cd /opt
git clone https://github.com/luismiguelbp/docker.git
cd docker
chmod +x scripts/*.sh

# 4) Install Docker (supported on Debian/Ubuntu only)
sudo ./scripts/docker-setup.sh install

# 5) Create data folders and permissions (also generates /opt/docker/.env if missing)
sudo ./scripts/docker-setup.sh init /opt/docker

# 6) Edit the generated environment file BEFORE starting services
nano /opt/docker/.env

# 7) Copy required configuration templates (at minimum Mosquitto)
cp templates/mosquitto/config/mosquitto.conf /opt/docker/data/mosquitto/config/

# 8) Start the selected services
docker compose up -d
docker compose ps
```

## License

See [LICENSE](LICENSE) file.
