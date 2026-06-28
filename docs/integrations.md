# Integration Plan

This repository keeps the first version of the Home Assistant setup safe and maintainable by using placeholders instead of guessing device-specific registers or credentials.

## Growatt PV, battery, and meter

Preferred order:

1. local integration if a stable local path is available
2. Modbus TCP if the inverter or meter exposes a verified register map
3. Growatt cloud integration only if local access is not possible

Model these values once the data source is known:

- PV production
- battery SoC
- battery charge and discharge power
- grid import and export
- house consumption
- inverter status
- smart meter values from DTSU666 or CHNT_THREE

Do not hardcode IP addresses, usernames, passwords, or register numbers here.
Use placeholders until the actual device documentation has been verified.

The `growatt.yaml` package keeps the first version practical by exposing template sensors that can fall back to manual helper values when a raw local or cloud entity is not available yet.
The `input_select.growatt_data_source` helper lets you force manual fallback or document which live source is active once the real integration exists.
Store any Growatt login data in the persistent `secrets.yaml` file documented in [`docs/secrets.md`](secrets.md).

## Balcony PV

Treat the 800 W balcony system as a separate producer because the Growatt system does not account for it.

Preferred measurement options:

- a dedicated local plug or energy meter
- another compatible local meter with live power reporting

Fallback and source selection:

- `input_select.balcony_pv_data_source` to force the estimated helper during setup or testing
- the manual helper `input_number.balcony_pv_estimated_power_w` for the actual fallback value

The `balcony_pv.yaml` package turns the helper into a usable sensor until a dedicated meter is available.

The current balcony setup should be documented against the actual hardware so the 860 W module set and the 800 W inverter limit stay explicit in the project.

## Energy dashboard readiness

The `energy.yaml` package now provides two layers:

- live power sensors in W for current-state automations and overview cards
- integrated kWh sensors for Home Assistant's Energy dashboard and longer-term tracking

The kWh sensors are derived from the live power entities so the setup stays useful before any device-specific energy counters are added.

## Heat pump placeholders

The `heatpump.yaml` package follows the same safe pattern as the Growatt helpers:

- live power and status templates remain readable even if the raw entities are missing
- optional manual override helpers keep the setup usable during early integration work
- nothing in this repository turns heating functions on or off automatically

## Additional devices to map

The user also has these device groups that still need explicit integration decisions:

- SmartLife outlets
- Meross garage door opener
- 860 W balcony set with Deye 800 W inverter

Track them in [`docs/device-inventory.md`](device-inventory.md) before adding packages or automations.

## HACS

The repository also includes [`docs/hacs.md`](hacs.md) and `scripts/install-hacs.sh`
so HACS can be installed cleanly once the Home Assistant container is running.

## Dimplex LAW-14ITR / WPM Touch / NWPM Touch

Likely integration path:

- verify whether the controller exposes Modbus TCP
- document the controller IP address, port, unit ID, and register map
- build against verified documentation only

Future control concepts to document later:

- PV surplus mode
- battery SoC threshold logic
- SG-Ready enable and disable logic
- optional dynamic electricity price optimization

Safety requirements:

- do not short-cycle the heat pump
- enforce minimum runtime and minimum pause behavior in future automations
- keep critical heating functions conservative

## Energy dashboard

For energy dashboard friendly sensors, use:

- `device_class: power` for W sensors
- `device_class: battery` for state of charge
- `state_class: measurement` for live power values
- integrated energy sensors with kWh units for long-term tracking
- a proper `unit_of_measurement`

## What stays intentionally out of scope for now

- exact Growatt register numbers
- exact Dimplex register numbers
- aggressive automation for heating
- any internet-facing Home Assistant exposure

