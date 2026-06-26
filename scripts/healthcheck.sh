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

: "${HA_BASE_URL:=http://127.0.0.1:8123}"
: "${HA_LONG_LIVED_TOKEN:=}"

if ! command -v docker >/dev/null 2>&1; then
  printf '%s\n' 'docker is required for healthchecks.' >&2
  exit 1
fi

state=$(docker inspect -f '{{.State.Running}}' homeassistant 2>/dev/null || true)
if [ "$state" != 'true' ]; then
  printf '%s\n' 'Home Assistant container is not running.' >&2
  exit 1
fi

if command -v curl >/dev/null 2>&1; then
  if ! curl -fsS --max-time 10 "$HA_BASE_URL/" >/dev/null; then
    printf '%s\n' 'Home Assistant is not reachable on port 8123.' >&2
    exit 1
  fi
  if [ -n "$HA_LONG_LIVED_TOKEN" ]; then
    if ! curl -fsS --max-time 10 -H "Authorization: Bearer $HA_LONG_LIVED_TOKEN" "$HA_BASE_URL/api/config" >/dev/null; then
      printf '%s\n' 'Home Assistant API check failed.' >&2
      exit 1
    fi
  fi
else
  printf '%s\n' 'curl is required for the healthcheck.' >&2
  exit 1
fi

printf '%s\n' 'Healthcheck passed.'
