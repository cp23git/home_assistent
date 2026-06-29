# Secrets

Keep credentials out of Git and store them in the persistent Home Assistant
config directory instead.

## Recommended location

Use `/volume1/docker/homeassistant/config/secrets.yaml` on Synology.

That file stays on the NAS shared folder, so it survives container restarts
and is not touched by the repository sync step. The sync script backs it up
before copying the repository config and restores it afterwards.

## Example values

The exact key names depend on the integration you choose, but the pattern is:

```yaml
growatt_username: your-username
growatt_password: your-password
smartlife_username: your-username
smartlife_password: your-password
meross_email: your-email@example.com
meross_password: your-password
```

## Notes

- Do not commit the real `secrets.yaml` file.
- Keep any vendor login data in the persistent config directory only.
- If an integration supports `!secret`, point it at the keys in
  `secrets.yaml`.
