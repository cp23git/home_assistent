#!/bin/sh
set -eu
set -o pipefail 2>/dev/null || true

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

if [ -f "$ROOT_DIR/.env" ]; then
  set -a
  . "$ROOT_DIR/.env"
  set +a
fi

cd "$ROOT_DIR"

: "${HA_CONFIG_PATH:=/volume1/docker/homeassistant/config}"
: "${BACKUP_DIR:=$ROOT_DIR/backups}"
: "${BACKUP_RETENTION_COUNT:=10}"

resolve_docker() {
  if command -v docker >/dev/null 2>&1; then
    command -v docker
    return
  fi
  if [ -x /usr/local/bin/docker ]; then
    printf '%s\n' /usr/local/bin/docker
    return
  fi
  printf '%s\n' 'docker is required but was not found in PATH or /usr/local/bin/docker.' >&2
  exit 1
}

compose() {
  docker_bin=$(resolve_docker)
  if "$docker_bin" compose version >/dev/null 2>&1; then
    "$docker_bin" compose "$@"
    return
  fi
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
    return
  fi
  printf '%s\n' 'docker compose or docker-compose is required.' >&2
  exit 1
}

printf '%s\n' 'Preparing Home Assistant deployment...'
printf 'Config path: %s\n' "$HA_CONFIG_PATH"
mkdir -p "$BACKUP_DIR"

printf '%s\n' 'Syncing Home Assistant config files...'
"$ROOT_DIR/scripts/sync-config.sh"

printf '%s\n' 'Pulling the stable Home Assistant image...'
compose -f "$ROOT_DIR/docker-compose.yml" pull homeassistant

printf '%s\n' 'Starting or recreating the container...'
compose -f "$ROOT_DIR/docker-compose.yml" up -d --force-recreate homeassistant

printf '%s\n' 'Running healthcheck...'
"$ROOT_DIR/scripts/healthcheck.sh"

printf '%s\n' 'Deployment completed successfully.'
