# Live Entity Inventory

This page captures the entity IDs that currently exist in Home Assistant and
return useful values for dashboards.

The key rule for the dashboards is simple: use the live entity IDs below
instead of the old `_w` placeholders.

## Energy And Power

| Entity ID | Current state | Notes |
| --- | ---: | --- |
| `sensor.fnpaf5n02h_ausgangsleistung` | `58.3` W | Growatt AC output, includes battery interaction |
| `sensor.fnpaf5n02h_interne_leistung` | varies | Growatt PV input power (`ppv`) |
| `sensor.fnpaf5n02h_eigene_leistung` | `159.0` W | Live own power figure from the same source |
| `sensor.fnpaf5n02h_energie_heute` | `20.2` kWh | PV energy today |
| `sensor.fnpaf5n02h_systemerzeugung_heute` | `4.3` kWh | System generation today |
| `sensor.fnpaf5n02h_gesamte_pv_energie_uber_lebensdauer` | `139.0` kWh | PV lifetime production |
| `sensor.fnpaf5n02h_gesamtlastverbrauch_uber_lebensdauer` | `14.9` kWh | Lifetime load consumption |
| `sensor.fnpaf5n02h_lokale_lastleistung` | `138.0` W | Live local load |
| `sensor.fnpaf5n02h_bezugsleistung` | `0.0` W | Grid import |
| `sensor.fnpaf5n02h_einspeiseleistung` | `0.0` W | Grid export |
| `sensor.fnpaf5n02h_ladezustand_soc` | `95` % | Battery state of charge |
| `sensor.solarman_inverter_total_production` | `1923.7` kWh | Inverter total production |
| `sensor.pc_leistung` | `122.8` W | SmartLife / Tuya outlet load |
| `sensor.pc_energie_gesamt` | `1.59` kWh | SmartLife / Tuya outlet total energy |
| `sensor.1_warmepumpe_wasser_leistung` | `4.9` W | Heat pump live power |
| `sensor.4_pv_oben_leistung` | `0.5` W | Additional PV channel |
| `sensor.terrasse_total_ausgangsleistung` | `65.8` W | Terrace total output |

## Controls

| Entity ID | Current state | Notes |
| --- | ---: | --- |
| `cover.meross_garage_door` | `opening` | Meross garage opener |
| `switch.pc_steckdose_1` | `on` | SmartLife / Tuya switch |
| `switch.smartlife_primary_outlet` | `off` | Repository helper switch |
| `switch.4_pv_oben_steckdose_1` | `on` | PV-related switch |
| `switch.1_warmepumpe_wasser_steckdose_1` | `off` | Heat pump switch |

## Live Helpers Still Available

The following helpers were repaired against the live registry on 2026-09-25.
They now use real upstream measurements and report unavailable for missing data.
The numerical values in the historical inventory above are examples, not current
readings.

- `sensor.total_home_supply`
- `sensor.total_home_generation`
- `sensor.home_pv_surplus`
- `sensor.home_grid_import`
- `sensor.home_grid_export`
- `sensor.home_battery_soc`
- `sensor.home_heat_pump_consumption`

`sensor.total_home_generation` sums Growatt PV, Solarman output, and PV oben.
The PC outlet is not counted as a producer. The seven derived kWh counters now
use these real entity IDs and begin accumulating from the repair onward.

Growatt battery and signed grid power use native readings, with positive values
for discharge and import respectively. The old -20000/-30000 helper minima are
not accepted as measurements. Dimplex mode uses holding register 5015; 5007 was
the controller's clock minute.
