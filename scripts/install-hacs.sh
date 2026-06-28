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

: "${HA_CONTAINER_NAME:=homeassistant}"

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

docker_bin=$(resolve_docker)

if ! "$docker_bin" inspect "$HA_CONTAINER_NAME" >/dev/null 2>&1; then
  printf 'Container %s was not found.\n' "$HA_CONTAINER_NAME" >&2
  exit 1
fi

if ! "$docker_bin" inspect -f '{{.State.Running}}' "$HA_CONTAINER_NAME" 2>/dev/null | grep -qi '^true$'; then
  printf 'Container %s is not running.\n' "$HA_CONTAINER_NAME" >&2
  exit 1
fi

printf '%s\n' 'Downloading HACS into the Home Assistant container...'
"$docker_bin" exec "$HA_CONTAINER_NAME" bash -lc 'wget -O - https://get.hacs.xyz | bash -'

printf '%s\n' 'Restarting Home Assistant to load HACS...'
"$docker_bin" restart "$HA_CONTAINER_NAME" >/dev/null

printf '%s\n' 'HACS installation helper completed.'
printf '%s\n' 'Finish by opening Home Assistant and adding the HACS integration from Settings > Devices & services.'
