# Device Inventory

This file tracks the additional devices that still need an integration path or
placeholder package.

## SmartLife outlets

- capture the exact outlet count and room names
- confirm whether each outlet should be exposed as a switch, power sensor, or both
- prefer a documented local or vendor-supported path before adding automations

## Meross garage door opener

- capture the exact model number and whether the unit exposes a full cover entity
- confirm whether a local integration path is available before relying on cloud access
- keep the door state, command, and any safety sensor separate in the final setup

## 860 W balcony set with Deye 800 W inverter

- keep the AC power helper capped to inverter output, not module nameplate power
- document the inverter model, relay capability, and any energy reporting source
- treat the balcony set as a separate producer in the energy helpers

## What still needs to be chosen

- the exact integration path for the SmartLife outlets
- the exact integration path for the Meross opener
- the exact data source for the Deye inverter and balcony set
