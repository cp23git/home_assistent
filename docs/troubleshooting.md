# Troubleshooting

## Home Assistant does not start

- Check `docker logs homeassistant`.
- Confirm the config path exists and is writable.
- Validate that the mounted path really points at the Synology shared folder.

## Home Assistant is not reachable on port 8123

- Confirm the container is running.
- Confirm `network_mode: host` is still in place.
- Check firewall rules on the NAS and the client machine.

## Discovery does not work

Host networking should make mDNS and local discovery easier.
If discovery still fails, verify the device itself and the NAS LAN connectivity.

## Update problems

- Run `scripts/healthcheck.sh` first to verify the base state.
- Run `scripts/update-homeassistant.sh` to update safely.
- If the healthcheck fails after an update, restore the latest backup with `scripts/rollback.sh latest`.

## Backup problems

- Confirm that `BACKUP_DIR` exists or is writable.
- Confirm that `HA_CONFIG_PATH` points to the actual config directory.
- Check that there is enough free space on the NAS.

## Integration placeholders show unknown

That is expected until the real device integration is connected.
The package files are intentionally placeholder-based so the project remains safe and editable.
