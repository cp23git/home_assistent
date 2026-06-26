# Home Assistant on Synology

This repository provides a production-ready Home Assistant Core deployment for a Synology NAS using Container Manager or plain Docker Compose.

## What is included

- `docker-compose.yml` for the official Home Assistant container
- persistent config handling through a Synology shared folder
- controlled backup, update, healthcheck, and rollback scripts
- a minimal Home Assistant base configuration
- package placeholders for Growatt, balcony PV, and heat pump integration work
- deployment and troubleshooting documentation

## Quick start

1. Create a Synology shared folder such as `/volume1/docker/homeassistant/config`.
2. Copy `.env.example` to `.env` and adjust paths if needed.
3. Ensure Docker or Container Manager is installed on the Synology NAS.
4. Deploy and sync the config from the repository root:

```sh
./scripts/deploy.sh
```

5. Open Home Assistant at `http://<synology-ip>:8123`.

## Update workflow

Use `scripts/update-homeassistant.sh` instead of blind auto-updates. The update script creates a backup first, pulls the stable image, recreates the container, and runs a healthcheck.

## Backup and restore

- `scripts/backup.sh` creates a timestamped archive of the persistent config.
- `scripts/rollback.sh` restores the latest backup or a selected archive.
- `docs/backup-restore.md` explains the restore process in more detail.

## Important notes

- Do not expose Home Assistant directly to the internet.
- Use LAN access first, or add Home Assistant Cloud, VPN, or a properly protected reverse proxy later.
- Do not store secrets in Git. Keep them in `.env`, `secrets.yaml`, or Synology-managed secret storage.

## Repository layout

- `homeassistant/` holds the configuration used as the starting point for the Home Assistant setup.
- `scripts/sync-config.sh` copies the repository configuration into the persistent Synology config path.
- `scripts/` holds operational scripts for deploy, backup, update, healthcheck, and rollback.
- `docs/` holds the Synology and integration guidance.

## Acceptance criteria

- `docker compose up -d` starts Home Assistant.
- Home Assistant is reachable on `http://<synology-ip>:8123`.
- Config survives container recreation.
- Backups are restorable.
- Updates are backed by a pre-update backup and a healthcheck.
- Unsafe heat pump control is not enabled by default.
