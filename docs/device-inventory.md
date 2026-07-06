# Device Inventory

This file tracks the additional devices that still need an integration path or
placeholder package.

## SmartLife outlets

- currently bound through the existing Tuya integration
- the primary outlet is mapped to `switch.pc_steckdose_1`
- the live power sensor for that outlet is `sensor.pc_leistung`
- capture the exact outlet count and room names
- confirm whether each outlet should be exposed as a switch, power sensor, or both
- no SmartLife credentials are stored in Git for the current local setup

## Meross garage door opener

- likely paths are the official Meross integration or Meross LAN via HACS
- the template now accepts a configurable raw cover entity once the live Meross entity is known
- on the current live setup `cover.meross_garage_door` is registered and currently reports `opening`
- capture the exact model number and whether the unit exposes a full cover entity
- confirm whether a local integration path is available before relying on cloud access
- keep the door state, command, and any safety sensor separate in the final setup

## 860 W balcony set with Deye 800 W inverter

- the balcony set is modeled in `homeassistant/packages/balcony_pv.yaml`
- the live power source currently comes from `sensor.fnpaf5n02h_ausgangsleistung`
- keep the AC power helper capped to inverter output, not module nameplate power
- document the inverter model, relay capability, and any energy reporting source
- treat the balcony set as a separate producer in the energy helpers

## Heat pump

- the live power sensor is `sensor.1_warmepumpe_wasser_leistung`
- the heat pump helper remains available as `sensor.heat_pump_power`
- Modbus TCP is reachable from the Home Assistant container at `192.168.178.34:502`
- the Dimplex/NWPM Modbus hub is modeled as `dimplex` with unit/slave `1`
- verified read-only input registers on the live controller:
  - `5007` Dimplex community mode/reference currently returned changing values such as `43`, `46`, and `51`
  - `5167` Smart Grid currently returned `11`
  - `5002` parallel displacement currently returned `1`
  - `5022` hot water target raw currently returned `1`
  - `5088` max temperature raw currently returned `0`
  - `30` hot water temperature currently returned `0`
  - `40` hot water target temperature currently returned `0`
  - `714` operating mode currently returned `0`
  - `502` room target temperature currently returned `200` (`20.0 C`)
  - `1294` heating return temperature currently returned `328` (`32.8 C`)
  - `1300` heating supply temperature currently returned `319` (`31.9 C`)
  - `1305` warm water temperature currently returned `470` (`47.0 C`)
  - `1246` Smart Grid state currently returned `0`
  - `1472` compressor speed currently returned `0`
  - `1500` compressor status currently returned `0`
  - `1586` heat pump live status currently returned `0`
- do not enable write automations for mode control until the register map and the
  meaning of the changing community mode values are confirmed
- use the live raw sensor in dashboards until the helper is wired to a stable source

## What still needs to be chosen

- the exact integration path for the Meross opener
- the exact data source for the Deye inverter and balcony set
