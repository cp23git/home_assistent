# Backup and Restore

## Backup behavior

`scripts/backup.sh` creates a timestamped tarball of the persistent config directory.
The archive contains the current Home Assistant configuration and data files that live in the mounted config path.

## Retention

Backups are kept according to `BACKUP_RETENTION_COUNT`.
Set the value in `.env` if you want to keep more or fewer archives.

## Restore behavior

`scripts/rollback.sh` can restore:

- the latest backup
- a numbered selection from the available list
- an explicit archive path

The restore process stops Home Assistant, clears the config directory, extracts the chosen backup, recreates the container, and then runs the healthcheck.

## Practical recommendation

Keep one copy of the backup directory on the NAS and optionally mirror it with Synology Hyper Backup if you already use that tool.
Do not assume Hyper Backup exists unless you configure it yourself.
