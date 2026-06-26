# Update Strategy

## Default approach

Do not use blind auto-updates for Home Assistant Core.
Home Assistant updates should be deliberate, backed by a fresh backup, and followed by a healthcheck.

## Recommended flow

Use `scripts/update-homeassistant.sh`.
The script performs these steps:

1. prints the currently installed image and version information when available
2. creates a timestamped backup of the config directory
3. pulls `ghcr.io/home-assistant/home-assistant:stable`
4. recreates the container using Docker Compose
5. runs `scripts/healthcheck.sh`
6. prints rollback guidance if the healthcheck fails

## Backup retention

The backup script keeps the newest backups according to `BACKUP_RETENTION_COUNT`.
The default is 10 backups.

## Why Watchtower is not the default

Watchtower can be useful in some environments, but it is not the recommended default for unattended Home Assistant Core updates because:

- it removes the change window that is useful for checking release notes
- it can update at an inconvenient time
- it makes rollback timing less obvious
- it is harder to pair with manual validation on a home automation system

If you choose to use it later, document it as an explicit exception and keep the manual update path available.
