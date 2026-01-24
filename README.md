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

## Quick Start

### 1. Clone and Configure

```bash
# Clone the repository
git clone https://github.com/luismiguelbp/docker.git /opt/docker
cd /opt/docker

# Ensure scripts are executable
chmod +x scripts/*.sh

# Copy and edit the environment file
cp .env.example .env
nano .env
```

### 2. Create Folders and Set Permissions

```bash
# Create required directories and set permissions
sudo ./scripts/docker-setup.sh init /opt/docker

# Or run steps individually
sudo ./scripts/docker-setup.sh create /opt/docker
sudo ./scripts/docker-setup.sh perms /opt/docker
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

## Initial System Setup (Debian/Ubuntu)

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

## License

See [LICENSE](LICENSE) file.
