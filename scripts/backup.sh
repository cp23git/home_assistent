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

if [ ! -d "$HA_CONFIG_PATH" ]; then
  mkdir -p "$HA_CONFIG_PATH"
fi
mkdir -p "$BACKUP_DIR"

stamp=$(date +%Y%m%d-%H%M%S)
archive="$BACKUP_DIR/homeassistant-config-$stamp.tar.gz"

printf 'Creating backup: %s\n' "$archive"
tar -C "$HA_CONFIG_PATH" -czf "$archive" .

set -- "$BACKUP_DIR"/homeassistant-config-*.tar.gz
if [ "${1:-}" != "$BACKUP_DIR/homeassistant-config-*.tar.gz" ]; then
  total=$#
  if [ "$total" -gt "$BACKUP_RETENTION_COUNT" ]; then
    remove=$((total - BACKUP_RETENTION_COUNT))
    count=0
    for item in "$@"; do
      count=$((count + 1))
      if [ "$count" -le "$remove" ]; then
        printf 'Removing old backup: %s\n' "$item"
        rm -f -- "$item"
      fi
    done
  fi
fi

printf 'Backup finished: %s\n' "$archive"
