import asyncio
import json
from pathlib import Path

import yaml
from homeassistant.core import HomeAssistant
from homeassistant.helpers.template import Template

files = globals().get('CANDIDATE_FILES') or {
    name: (Path('/config') / name).read_text()
    for name in ['packages/energy.yaml', 'packages/growatt.yaml', 'packages/balcony_pv.yaml', 'packages/heatpump.yaml', 'dashboards/devices.yaml']
}
configs = {name: yaml.safe_load(text) for name, text in files.items()}
registry = json.loads(Path('/config/.storage/core.entity_registry').read_text())['data']['entities']
entity_ids = {e['unique_id']: e['entity_id'] for e in registry if e['platform'] == 'template'}
templates = [sensor for name, config in configs.items() for block in config.get('template', []) for sensor in block.get('sensor', [])]
failures = []
checks = 0

def check(condition, message):
    global checks
    checks += 1
    if not condition:
        failures.append(message)

async def main():
    hass = HomeAssistant('/tmp/ha-helper-regression')
    def set_state(entity, state):
        hass.states.async_set(entity, str(state))
    def number(entity):
        state = hass.states.get(entity)
        try:
            return float(state.state) if state else None
        except ValueError:
            return None
    def render():
        for _ in range(4):
            for sensor in templates:
                eid = entity_ids.get(sensor['unique_id'])
                if not eid:
                    continue
                try:
                    available = Template(str(sensor.get('availability', '{{ true }}')), hass).async_render()
                    value = Template(str(sensor['state']), hass).async_render() if available else 'unavailable'
                    set_state(eid, value)
                except Exception as exc:
                    failures.append(f'{eid}: template error: {exc}')
    native = {
        'sensor.fnpaf5n02h_interne_leistung': 1000,
        'sensor.fnpaf5n02h_ausgangsleistung': 230,
        'sensor.fnpaf5n02h_ladezustand_soc': 45,
        'sensor.fnpaf5n02h_lokale_lastleistung': 600,
        'sensor.fnpaf5n02h_bezugsleistung': 50,
        'sensor.fnpaf5n02h_einspeiseleistung': 0,
        'sensor.fnpaf5n02h_batterie_1_aufladung_w': 800,
        'sensor.fnpaf5n02h_batterie_2_aufladung_w': 0,
        'sensor.fnpaf5n02h_batterie_1_entladung_w': 0,
        'sensor.fnpaf5n02h_batterie_2_entladung_w': 0,
        'sensor.solarman_inverter_power': 200,
        'sensor.4_pv_oben_leistung': 100,
        'sensor.pc_leistung': 250,
        'sensor.1_warmepumpe_wasser_leistung': 5.2,
    }
    for eid, value in native.items():
        set_state(eid, value)
    set_state('input_select.growatt_data_source', 'growatt_cloud')
    set_state('input_select.balcony_pv_data_source', 'deye_local')
    set_state('input_number.growatt_battery_power_override_w', -20000)
    set_state('input_number.growatt_meter_power_override_w', -30000)
    set_state('input_number.balcony_pv_estimated_power_w', 0)
    render()
    for eid, expected in {
        'sensor.growatt_pv_power': 1000,
        'sensor.growatt_battery_power': -800,
        'sensor.growatt_meter_power': 50,
        'sensor.home_battery_soc': 45,
        'sensor.balcony_pv_power': 200,
        'sensor.total_home_generation': 1300,
        'sensor.total_home_supply': 1350,
        'sensor.total_home_consumption': 600,
        'sensor.home_heat_pump_consumption': 5.2,
    }.items():
        check(number(eid) == expected, f'{eid}: expected {expected}, got {number(eid)}')
    for integral in configs['packages/energy.yaml']['sensor']:
        check(hass.states.get(integral['source']) is not None, f'Missing integration source: {integral["source"]}')
    for eid in native:
        set_state(eid, 'unavailable')
    render()
    for eid in ['sensor.growatt_battery_power', 'sensor.growatt_meter_power', 'sensor.home_battery_soc', 'sensor.total_home_generation', 'sensor.total_home_consumption', 'sensor.balcony_pv_power', 'sensor.home_heat_pump_consumption']:
        check(hass.states.get(eid).state == 'unavailable', f'{eid}: missing input must be unavailable')
    set_state('input_select.growatt_data_source', 'manual_fallback')
    render()
    for eid in ['sensor.growatt_battery_power', 'sensor.growatt_meter_power']:
        check(hass.states.get(eid).state == 'unavailable', f'{eid}: uninitialized minimum must not become a reading')
    set_state('input_number.growatt_battery_power_override_w', -150)
    set_state('input_number.growatt_meter_power_override_w', -250)
    render()
    check(number('sensor.growatt_battery_power') == -150, 'Explicit manual battery override must work')
    check(number('sensor.growatt_meter_power') == -250, 'Explicit manual meter override must work')
    set_state('input_select.growatt_data_source', 'growatt_cloud')
    for eid, value in native.items():
        set_state(eid, value)
    set_state('sensor.fnpaf5n02h_batterie_1_aufladung_w', 0)
    set_state('sensor.fnpaf5n02h_batterie_1_entladung_w', 300)
    set_state('sensor.fnpaf5n02h_einspeiseleistung', 80)
    render()
    check(number('sensor.growatt_battery_power') == 300, 'Battery discharge must be positive after reconnection')
    check(number('sensor.growatt_meter_power') == -30, 'Grid power must equal import minus export')
    for sensor in configs['packages/heatpump.yaml']['modbus'][0]['sensors']:
        if sensor['unique_id'] in ['dimplex_mode', 'dimplex_operating_mode_raw']:
            check(sensor['address'] == 5015 and sensor['input_type'] == 'holding', f'{sensor["unique_id"]}: must use documented holding register 5015')
    for mode, expected in [(0, 'Sommer nur Warmwasser'), (1, 'Auto'), (5, 'Kuehlen')]:
        set_state('sensor.dimplex_mode', mode)
        set_state('sensor.dimplex_operating_mode_raw', mode)
        render()
        check(hass.states.get('sensor.dimplex_mode_text').state == expected, f'Legacy mode text wrong for {mode}')
        check(hass.states.get('sensor.dimplex_operating_mode_text').state == expected, f'Operating mode text wrong for {mode}')
    print(json.dumps({'checks': checks, 'failures': failures}))

asyncio.run(main())
if failures:
    raise SystemExit(1)
