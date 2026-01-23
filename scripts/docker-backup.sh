#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_common.sh
source "$SCRIPT_DIR/_common.sh"

print_usage() {
  cat <<EOF
Usage:
  ./scripts/docker-backup.sh [dest_path]

Description:
  Creates a compressed tarball of the Docker 'data' directory.
  If dest_path is not provided, it defaults to /tmp/docker-backups.

Example:
  ./scripts/docker-backup.sh /mnt/backups/docker
EOF
}

perform_backup() {
  local dest_path="${1:-/tmp/docker-backups}"
  local docker_path
  docker_path="$(get_docker_path "")"
  local data_path="$docker_path/data"
  local timestamp
  timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_file="$dest_path/docker_backup_$timestamp.tar.gz"

  echo "Starting backup of: $data_path"
  echo "Destination: $backup_file"

  if [ ! -d "$data_path" ]; then
    echo "Error: Source directory $data_path does not exist."
    exit 1
  fi

  # Create destination directory if it doesn't exist
  mkdir -p "$dest_path"

  # Optional: Stop containers for data consistency
  # echo "Stopping containers..."
  # docker compose down

  echo "Compressing data... (this may take a while)"
  # We use $SUDO to ensure we can read all service directories (postgres, mosquitto, etc.)
  if $SUDO tar -czf "$backup_file" -C "$docker_path" "data"; then
    echo "Backup completed successfully!"
    $SUDO chown "$(id -u):$(id -g)" "$backup_file"
    echo "File size: $(du -h "$backup_file" | cut -f1)"
  else
    echo "Error: Backup failed."
    exit 1
  fi

  # Optional: Restart containers
  # echo "Starting containers..."
  # docker compose up -d
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  print_usage
  exit 0
fi

perform_backup "${1:-}"
