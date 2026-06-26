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

list_backups() {
  ls -1t "$BACKUP_DIR"/homeassistant-config-*.tar.gz 2>/dev/null || true
}

show_backups() {
  backups=$(list_backups)
  if [ -z "$backups" ]; then
    printf '%s\n' 'No backups found.'
    return 1
  fi
  printf '%s\n' "$backups" | awk '{ printf "%d. %s\n", NR, $0 }'
}

choice=${1:-latest}

if [ "$choice" = 'list' ]; then
  show_backups
  exit 0
fi

if [ ! -d "$BACKUP_DIR" ]; then
  printf 'Backup directory does not exist: %s\n' "$BACKUP_DIR" >&2
  exit 1
fi

backup=''
case "$choice" in
  latest|'')
    backup=$(list_backups | sed -n '1p')
    ;;
  [0-9]*)
    backup=$(list_backups | sed -n "${choice}p")
    ;;
  */*|*.tar.gz)
    backup=$choice
    ;;
  *)
    backup=$(list_backups | sed -n '1p')
    ;;
esac

if [ -z "$backup" ] || [ ! -f "$backup" ]; then
  printf '%s\n' 'No usable backup archive found.' >&2
  exit 1
fi

printf 'Restoring backup: %s\n' "$backup"
mkdir -p "$HA_CONFIG_PATH"
compose -f "$ROOT_DIR/docker-compose.yml" down || true
find "$HA_CONFIG_PATH" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
tar -C "$HA_CONFIG_PATH" -xzf "$backup"
compose -f "$ROOT_DIR/docker-compose.yml" up -d --force-recreate homeassistant
"$ROOT_DIR/scripts/healthcheck.sh"
printf '%s\n' 'Rollback completed successfully.'
