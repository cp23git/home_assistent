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

The `growatt.yaml` package defaults to the existing FNPAF5N02H Growatt cloud entities.
`input_select.growatt_data_source` can explicitly select local Modbus or manual values.
An unavailable live sensor stays unavailable; it never silently falls back to a manual value.
The signed battery and meter helpers reject their uninitialized input-number minima.
Battery power is positive when discharging; meter power is positive when importing.
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

The `balcony_pv.yaml` package defaults to `sensor.solarman_inverter_power` from
the HACS Solarman integration. Estimates require explicitly selecting `estimated`.
When the inverter sleeps or loses its connection, the helper and dependent sums
are unavailable instead of assuming zero production.

## Energy dashboard readiness

The `energy.yaml` package now provides two layers:

- live power sensors in W for current-state automations and overview cards
- integrated kWh sensors for Home Assistant's Energy dashboard and longer-term tracking

The kWh sensors are derived from the live power entities so the setup stays useful before any device-specific energy counters are added.
`sensor.total_home_generation` sums Growatt PV (`ppv`, not battery-backed AC
output), Deye/Solarman output and the Tuya `sensor.4_pv_oben_leistung` meter.
These are different measurement points (Growatt DC input and microinverter AC
output); the sum is a production overview, not a loss-adjusted AC house balance.
`sensor.total_home_supply` adds grid import to that sum. It does not represent
house consumption or include battery discharge a second time as PV generation.
`sensor.total_home_consumption` follows the actual Growatt local-load reading.
All seven integral sensors reference actual entity IDs, without the old `_w`
suffixes that belong to unique IDs. They accumulate kWh from deployment onward;
missing historical measurements are not backfilled.
The live dashboards now prefer actual entity IDs that currently exist in Home Assistant, for example `sensor.fnpaf5n02h_ausgangsleistung`, `sensor.fnpaf5n02h_eigene_leistung`, `sensor.pc_leistung`, `sensor.1_warmepumpe_wasser_leistung`, `switch.pc_steckdose_1`, and `cover.meross_garage_door`.
Helpers become unavailable if a required measurement is missing. Direct device
counters remain the preferred source for historical production totals.

## Heat pump Modbus

The `heatpump.yaml` package now exposes the Dimplex/NWPM controller through a
read-only Modbus TCP hub:

- hub name `dimplex`
- host `192.168.178.34`
- port `502`
- unit/slave `1`
- legacy input registers from the community example: `5167`,
  `5002`, `5022`, `5088`, `30`, `40`
- verified input registers from the installed Dimplex cloud integration
  variable list: `502`, `1246`, `1294`, `1300`, `1305`, `1472`,
  `1500`, `1586`
- both mode entities use holding register `5015`, confirmed read-only on this
  controller and against the manufacturer's NWPM J/L register map
- `5007` is the clock minute on this controller; it must not be decoded as mode
- mode codes: 0 summer, 1 auto, 2 holiday, 3 party, 4 second heat generator,
  5 cooling; the legacy mode text mirrors the primary mode text

The package still follows the same safe pattern as the Growatt helpers:

- live power templates report unavailable when their measurement is missing
- optional manual override helpers keep the setup usable during early integration work
- nothing in this repository turns heating functions on or off automatically
- the September 2026 repair only changes read-only sensors and display labels

Register reference: [Dimplex NWPM Modbus TCP](https://dimplex.atlassian.net/wiki/spaces/DW/pages/2900361221/).
Regression checks can be run inside the HA container without connecting to any
devices: `docker exec -i homeassistant python - < scripts/test-energy-helpers.py`.

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
