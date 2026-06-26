# Synology Setup

## Shared folder layout

Create a Synology shared folder that will hold the persistent Home Assistant data, for example:

- `/volume1/docker/homeassistant/config`
- `/volume1/docker/homeassistant/backups`

The config directory must remain persistent because it contains the Home Assistant database, dashboards, automations, package files, and `.storage` data.

## Container Manager or Docker Compose

Use either Synology Container Manager or a plain Docker Compose deployment.
The repository is intentionally simple so it works well with both paths.

### Container Manager

- Install Container Manager from Package Center.
- Import or create a project that points at this repository.
- Keep the project on host networking.
- Mount the config directory into `/config`.

### Plain Docker Compose

From the repository root run:

```sh
docker compose up -d
```

## Required permissions

The account running the container must be able to read and write the chosen shared folder.
If Container Manager asks for permissions, grant access to the Home Assistant config and backup paths.

## Why host networking is used

Host networking is the safest choice here because it improves local discovery and integration reliability for:

- mDNS
- SSDP
- Shelly discovery
- other local LAN integrations

It also avoids the extra troubleshooting that often comes with bridged networking on appliance-style NAS systems.

## Logs and restarts

- Check logs in Container Manager or by running `docker logs homeassistant`.
- Restart the container with `docker restart homeassistant` or from the Container Manager UI.

## Safe updates

Use `scripts/update-homeassistant.sh` rather than an unattended updater.
The update flow is:

1. create a backup
2. pull the stable image
3. recreate the container
4. run a healthcheck
5. roll back if the healthcheck fails

## Restoring a backup

Use `scripts/rollback.sh` with the latest archive or a selected one.
The restore path is:

1. stop Home Assistant
2. clear the config directory contents
3. extract the backup archive
4. recreate the container
5. verify the result with the healthcheck
