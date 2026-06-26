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

: "${HA_IMAGE:=ghcr.io/home-assistant/home-assistant:stable}"

compose() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    docker compose "$@"
    return
  fi
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
    return
  fi
  printf '%s\n' 'docker compose or docker-compose is required.' >&2
  exit 1
}

current_image=$(docker inspect -f '{{.Config.Image}}' homeassistant 2>/dev/null || true)
current_version='unknown'
if [ -n "$current_image" ] && docker image inspect "$current_image" >/dev/null 2>&1; then
  current_version=$(docker image inspect -f '{{index .Config.Labels "org.opencontainers.image.version"}}' "$current_image" 2>/dev/null || printf '%s' 'unknown')
fi

printf 'Current image: %s\n' "${current_image:-not installed yet}"
printf 'Current version: %s\n' "$current_version"
printf 'Target image: %s\n' "$HA_IMAGE"

printf '%s\n' 'Creating a pre-update backup...'
"$ROOT_DIR/scripts/backup.sh"

printf '%s\n' 'Pulling the stable image...'
compose -f "$ROOT_DIR/docker-compose.yml" pull homeassistant

printf '%s\n' 'Recreating the container...'
compose -f "$ROOT_DIR/docker-compose.yml" up -d --force-recreate homeassistant

printf '%s\n' 'Running healthcheck...'
if "$ROOT_DIR/scripts/healthcheck.sh"; then
  printf '%s\n' 'Update completed successfully.'
  exit 0
fi

printf '%s\n' 'Healthcheck failed after the update.' >&2
printf '%s\n' "To roll back, run: $ROOT_DIR/scripts/rollback.sh latest" >&2
exit 1
