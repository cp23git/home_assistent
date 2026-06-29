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
SECRETS_FILE="$HA_CONFIG_PATH/secrets.yaml"
SECRETS_BACKUP=''

if [ ! -d "$SOURCE_DIR" ]; then
  printf 'Source configuration directory not found: %s\n' "$SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$HA_CONFIG_PATH"

if [ -f "$SECRETS_FILE" ]; then
  SECRETS_BACKUP=$(mktemp "${TMPDIR:-/tmp}/homeassistant-secrets.XXXXXX")
  cp "$SECRETS_FILE" "$SECRETS_BACKUP"
fi

printf 'Syncing Home Assistant config from %s to %s\n' "$SOURCE_DIR" "$HA_CONFIG_PATH"
if command -v sudo >/dev/null 2>&1; then
  sudo -S -p '' cp -R "$SOURCE_DIR"/. "$HA_CONFIG_PATH"/
else
  cp -R "$SOURCE_DIR"/. "$HA_CONFIG_PATH"/
fi

if [ -n "$SECRETS_BACKUP" ] && [ -f "$SECRETS_BACKUP" ]; then
  cp "$SECRETS_BACKUP" "$SECRETS_FILE"
  rm -f "$SECRETS_BACKUP"
fi

printf '%s\n' 'Config sync finished.'
