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
SOURCE_DIR="$ROOT_DIR/homeassistant"

if [ ! -d "$SOURCE_DIR" ]; then
  printf 'Source configuration directory not found: %s\n' "$SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$HA_CONFIG_PATH"

printf 'Syncing Home Assistant config from %s to %s\n' "$SOURCE_DIR" "$HA_CONFIG_PATH"
cp -R "$SOURCE_DIR"/. "$HA_CONFIG_PATH"/
printf '%s\n' 'Config sync finished.'
