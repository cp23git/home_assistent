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
- use the live raw sensor in dashboards until the helper is wired to a stable source

## What still needs to be chosen

- the exact integration path for the Meross opener
- the exact data source for the Deye inverter and balcony set
