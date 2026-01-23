#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_common.sh
source "$SCRIPT_DIR/_common.sh"

print_usage() {
  cat <<'EOF'
Usage:
  ./scripts/docker-setup.sh init [docker_path]
  ./scripts/docker-setup.sh create [docker_path]
  ./scripts/docker-setup.sh perms [docker_path]
  ./scripts/docker-setup.sh ids
  ./scripts/docker-setup.sh install

Commands:
  init    Create folders/files and set permissions
  create  Create folders/files only
  perms   Set permissions only
  ids     Print user/group IDs and docker group
  install Install Docker on Debian/Ubuntu
EOF
}

create_dirs() {
  local docker_path="$1"

  echo "Creating Docker folders in: $docker_path"

  mkdir -p "$docker_path/data"

  local dirs=(
    "$docker_path/data/portainer/data"
    "$docker_path/data/mosquitto/config"
    "$docker_path/data/mosquitto/data"
    "$docker_path/data/mosquitto/log"
    "$docker_path/data/node-red/data"
    "$docker_path/data/grafana/data"
    "$docker_path/data/grafana/provisioning"
    "$docker_path/data/postgresql/data"
    "$docker_path/data/sqlite"
  )

  for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
      echo "$dir already exists."
    else
      mkdir -p "$dir"
    fi
  done

  # Mosquitto passwords file (empty)
  local passwords_file="$docker_path/data/mosquitto/config/passwords_file"
  if [ -f "$passwords_file" ]; then
    echo "$passwords_file exists."
  else
    touch "$passwords_file"
  fi

  # Environment file
  if [ -f "$REPO_ROOT/.env.example" ]; then
    if [ -f "$docker_path/.env" ]; then
      echo "$docker_path/.env exists."
    else
      cp "$REPO_ROOT/.env.example" "$docker_path/.env"
      echo "Created $docker_path/.env from .env.example."
    fi
  else
    echo "No .env.example found in $REPO_ROOT."
  fi

  echo ""
  echo "Next step: Copy required configuration files from templates/"
  echo "  cp templates/mosquitto/config/mosquitto.conf $docker_path/data/mosquitto/config/"
  echo ""
  echo "Done! Folders created in: $docker_path"
}

set_permissions() {
  local docker_path="$1"
  local uid
  local gid

  uid=$(get_docker_id "DOCKER_UID" "$(id -u)")
  gid=$(get_docker_id "DOCKER_GID" "$(id -g)")

  echo "Setting permissions for: $docker_path"
  echo "Using UID:GID -> $uid:$gid"

  if [ ! -d "$docker_path" ]; then
    echo "$docker_path does not exist."
    exit 1
  fi

  # Set base ownership to the docker group and the specified user
  $SUDO chown -R "$uid:$gid" "$docker_path"
  $SUDO chmod -R 755 "$docker_path"

  # Service-specific permissions (for images that run as specific non-root users)
  
  # Mosquitto (Standard UID 1883)
  if [ -d "$docker_path/data/mosquitto" ]; then
    echo "Setting Mosquitto specific permissions (UID 1883)..."
    $SUDO chown -R 1883:1883 "$docker_path/data/mosquitto"
  fi

  # PostgreSQL (Standard UID 70)
  if [ -d "$docker_path/data/postgresql" ]; then
    echo "Setting PostgreSQL specific permissions (UID 70)..."
    $SUDO chown -R 70:70 "$docker_path/data/postgresql"
  fi

  # Grafana (Standard UID 472 - but often overridden to DOCKER_UID in your compose)
  # Since your compose uses user: "${DOCKER_UID}:${DOCKER_GID}", 
  # the base chown $uid:$gid already covered it.

  # Files that need stricter permissions
  local secret_files=(
    "$docker_path/data/mosquitto/config/passwords_file"
    "$docker_path/.env"
  )

  for file in "${secret_files[@]}"; do
    if [ -f "$file" ]; then
      $SUDO chmod 600 "$file"
    fi
  done

  echo "Done! Permissions set for: $docker_path"
}

print_ids() {
  echo "User ID: $(id -u)"
  echo "Group ID: $(id -g)"
  echo "User root ID: $(id root -u)"
  echo "Group root ID: $(id root -g)"
  echo "Docker group entry: $(grep /etc/group -e 'docker')"
}

install_docker_debian() {
  if [ ! -f /etc/os-release ]; then
    echo "Cannot detect OS. This script supports Debian/Ubuntu only."
    exit 1
  fi

  # shellcheck disable=SC1091
  source /etc/os-release

  case "${ID:-}" in
    debian|ubuntu)
      ;;
    *)
      echo "Unsupported OS: ${ID:-unknown}. This script supports Debian/Ubuntu only."
      exit 1
      ;;
  esac

  echo "Install docker using the apt repository..."

  $SUDO apt update
  $SUDO apt install ca-certificates curl
  $SUDO install -m 0755 -d /etc/apt/keyrings
  $SUDO curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  $SUDO chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
  $SUDO apt update

  echo "Install the docker packages..."
  $SUDO apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "Start docker service..."
  #$SUDO service docker start
  $SUDO systemctl start docker.service
  $SUDO docker run hello-world

  echo "Enable docker service..."

  $SUDO systemctl enable docker.service
  $SUDO systemctl enable containerd.service

  # Configure groups and users
  #echo "Grant users using docker..."
  #$SUDO groupadd docker
  #$SUDO usermod -aG docker user
}

command="${1:-}"
arg="${2:-}"
docker_path="$(get_docker_path "${arg:-}")"

case "$command" in
  init)
    create_dirs "$docker_path"
    set_permissions "$docker_path"
    ;;
  create)
    create_dirs "$docker_path"
    ;;
  perms)
    set_permissions "$docker_path"
    ;;
  ids)
    print_ids
    ;;
  install)
    install_docker_debian
    ;;
  ""|help|-h|--help)
    print_usage
    ;;
  *)
    echo "Unknown command: $command"
    print_usage
    exit 1
    ;;
esac
