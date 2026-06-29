# Live Entity Inventory

This page captures the entity IDs that currently exist in Home Assistant and
return useful values for dashboards.

The key rule for the dashboards is simple: use the live entity IDs below
instead of the old `_w` placeholders.

## Energy And Power

| Entity ID | Current state | Notes |
| --- | ---: | --- |
| `sensor.fnpaf5n02h_ausgangsleistung` | `58.3` W | Live Deye / Solarman power output |
| `sensor.fnpaf5n02h_eigene_leistung` | `159.0` W | Live own power figure from the same source |
| `sensor.fnpaf5n02h_lokale_lastleistung` | `138.0` W | Live local load |
| `sensor.fnpaf5n02h_bezugsleistung` | `0.0` W | Grid import |
| `sensor.fnpaf5n02h_einspeiseleistung` | `0.0` W | Grid export |
| `sensor.fnpaf5n02h_ladezustand_soc` | `95` % | Battery state of charge |
| `sensor.solarman_inverter_total_production` | `1923.7` kWh | Inverter total production |
| `sensor.pc_leistung` | `122.8` W | SmartLife / Tuya outlet load |
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

These helper entities still exist, but many of them are currently zero because
their upstream source is not wired the way the dashboards used to expect.

- `sensor.total_home_supply`
- `sensor.total_home_generation`
- `sensor.home_pv_surplus`
- `sensor.home_grid_import`
- `sensor.home_grid_export`
- `sensor.home_battery_soc`
- `sensor.home_heat_pump_consumption`

For now, the dashboards should prefer the live entities above and only use the
helpers when they genuinely show a meaningful value.
