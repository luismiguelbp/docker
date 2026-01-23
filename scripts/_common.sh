#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Define SUDO prefix: empty if running as root, 'sudo' otherwise.
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  # Check if sudo is even installed
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    echo "Warning: Not running as root and 'sudo' command not found. Some operations may fail."
  fi
fi


get_docker_path() {
  local arg="${1:-}"
  local value=""

  if [ -n "$arg" ]; then
    echo "$arg"
    return
  fi

  if [ -n "${DOCKER_PATH:-}" ]; then
    echo "$DOCKER_PATH"
    return
  fi

  if [ -f "$REPO_ROOT/.env" ]; then
    value="$(awk -F= '$1=="DOCKER_PATH" {print $2; exit}' "$REPO_ROOT/.env")"
    value="${value%\"}"
    value="${value#\"}"
    value="${value%\'}"
    value="${value#\'}"
  fi

  if [ -n "$value" ]; then
    echo "$value"
    return
  fi

  echo "/opt/docker"
}

get_docker_id() {
  local var_name="$1"
  local default_value="$2"
  local value=""

  if [ -n "${!var_name:-}" ]; then
    echo "${!var_name}"
    return
  fi

  if [ -f "$REPO_ROOT/.env" ]; then
    value="$(awk -F= -v var="$var_name" '$1==var {print $2; exit}' "$REPO_ROOT/.env")"
    value="${value%\"}"
    value="${value#\"}"
    value="${value%\'}"
    value="${value#\'}"
  fi

  if [ -n "$value" ]; then
    echo "$value"
    return
  fi

  echo "$default_value"
}
