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

The `growatt.yaml` package keeps the first version practical by exposing
template sensors that can fall back to manual helper values when a raw local or
cloud entity is not available yet.

## Balcony PV

Treat the 800 W balcony system as a separate producer because the Growatt system does not account for it.

Preferred measurement options:

- a dedicated local plug or energy meter
- another compatible local meter with live power reporting

Fallback:

- the manual helper `input_number.balcony_pv_estimated_power_w`

The `balcony_pv.yaml` package turns the helper into a usable sensor until a dedicated meter is available.

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

The `energy.yaml` package prepares helpers for:

- grid import
- grid export
- PV production
- battery charge and discharge
- battery SoC
- house consumption
- balcony PV production
- heat pump consumption

For energy dashboard friendly sensors, use:

- `device_class: power` for W sensors
- `device_class: battery` for state of charge
- `state_class: measurement` for live power values
- a proper `unit_of_measurement`

## What stays intentionally out of scope for now

- exact Growatt register numbers
- exact Dimplex register numbers
- aggressive automation for heating
- any internet-facing Home Assistant exposure
