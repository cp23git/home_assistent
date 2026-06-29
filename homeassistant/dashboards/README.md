# Dashboards

This folder contains the versioned YAML dashboards used by the Synology setup.
The current dashboard sources are documented in `docs/live-entity-inventory.md`.

- `home.yaml` provides the main overview with the garage button and quick status cards.
- `energy.yaml` provides the energy page with the three-source power sum and graph cards.
- `devices.yaml` provides a device control page for garage, SmartLife, and source selectors.

Home Assistant loads them through the `lovelace` section in `configuration.yaml`.
