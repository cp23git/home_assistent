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
- `input_number.balcony_pv_module_nameplate_power_w` documents the 860 W module set
- `input_number.balcony_pv_inverter_limit_w` documents the 800 W Deye inverter limit

The `balcony_pv.yaml` package turns the helper into a usable sensor until a dedicated meter is available.
The HACS-installed Solarman integration is now available as a live path for the Deye balcony inverter and backs the default `sensor.solarman_inverter_power` raw entity used by the balcony PV package.
If that entity changes later, update the helper instead of hardcoding a new name into the template.

## Energy dashboard readiness

The `energy.yaml` package now provides two layers:

- live power sensors in W for current-state automations and overview cards
- integrated kWh sensors for Home Assistant's Energy dashboard and longer-term tracking

The kWh sensors are derived from the live power entities so the setup stays useful before any device-specific energy counters are added.
The `sensor.total_home_supply_w` helper combines Growatt PV, the Deye balcony inverter, and grid import so the dashboards can show the three-source power sum in one place.
The live dashboards now prefer actual entity IDs that currently exist in Home Assistant, for example `sensor.fnpaf5n02h_ausgangsleistung`, `sensor.fnpaf5n02h_eigene_leistung`, `sensor.pc_leistung`, `sensor.1_warmepumpe_wasser_leistung`, `switch.pc_steckdose_1`, and `cover.meross_garage_door`.
The helper sensors remain available as a fallback layer, but they should not be the only dashboard source anymore.

## Heat pump Modbus

The `heatpump.yaml` package now exposes the Dimplex/NWPM controller through a
read-only Modbus TCP hub:

- hub name `dimplex`
- host `192.168.178.34`
- port `502`
- unit/slave `1`
- verified input registers from the community example: `5007`, `5167`,
  `5002`, `5022`, `5088`, `30`, `40`
- verified input registers from the installed Dimplex cloud integration
  variable list: `714`, `502`, `1246`, `1294`, `1300`, `1305`, `1472`,
  `1500`, `1586`
- dashboards prefer the locally verified temperature and operating mode
  registers because they return plausible live values on this controller

The package still follows the same safe pattern as the Growatt helpers:

- live power and status templates remain readable even if one raw entity is missing
- optional manual override helpers keep the setup usable during early integration work
- nothing in this repository turns heating functions on or off automatically
- write automations stay out of scope until the meaning of the live mode value
  range from the community register `5007` is confirmed against the Dimplex
  register map

## Additional devices to map

The user also has these device groups that still need explicit integration decisions:

- SmartLife outlets, currently mapped through the existing Tuya integration
- Meross garage door opener, likely via the official Meross integration or Meross LAN
- 860 W balcony set with Deye 800 W inverter, already represented in the balcony PV package

Track them in [`docs/device-inventory.md`](device-inventory.md) before adding packages or automations.

## HACS

The repository also includes [`docs/hacs.md`](hacs.md) and `scripts/install-hacs.sh`
so HACS can be installed cleanly once the Home Assistant container is running.

## Dimplex LAW-14ITR / WPM Touch / NWPM Touch

Current integration path:

- Modbus TCP is enabled and reachable from the Home Assistant container
- the first read-only register set has been verified live
- dashboards show the raw Modbus values and safe text helpers
- the HACS/custom `dimplex` integration is installed on the live system but is
  currently only visible as update metadata; it is not the active local data
  path for the dashboards

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
- aggressive automation for heating
- Dimplex register writes or mode changes
- any internet-facing Home Assistant exposure
