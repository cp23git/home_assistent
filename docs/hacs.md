# HACS

The repository now includes a helper for installing HACS into the Home Assistant
container.

## Install

1. Make sure the Home Assistant container is running.
2. Run `scripts/install-hacs.sh` from the repository root.
3. Open Home Assistant and finish the HACS integration setup from the UI.

The helper follows the official HACS download flow for Container installs:

- enter the container
- run the HACS download script
- restart Home Assistant

## Notes

- HACS is a custom integration, so it should only be used when you are happy
  to manage third-party components.
- After installation, HACS can be used to browse and manage supported custom
  integrations and frontend resources.
