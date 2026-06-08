#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation
FILE=""
for candidate in "${LAB}/state-model.json" "${LAB}/state-model.yaml" "${LAB}/state-model.yml"; do
  [[ -f "${candidate}" ]] && FILE="${candidate}" && break
done
[[ -n "${FILE}" ]] || { echo "Нет state-model.json, state-model.yaml или state-model.yml"; exit 1; }
python3 - "${FILE}" <<'PY'
import json, pathlib, sys
p=pathlib.Path(sys.argv[1])
if p.suffix == '.json':
    data=json.loads(p.read_text())
else:
    try:
        import yaml
    except ImportError:
        raise SystemExit('Для проверки YAML требуется PyYAML; используйте JSON')
    data=yaml.safe_load(p.read_text())
required={'process_memory_assumption','filesystem_state','external_dependencies','endpoint'}
missing=required-set(data or {})
assert not missing, f'Отсутствуют разделы: {sorted(missing)}'
for key in required:
    assert isinstance(data[key], dict) and data[key], f'{key} должен быть непустым объектом'
e=data['endpoint']
assert e.get('path') == '/hib-status', 'endpoint.path должен быть /hib-status'
assert str(e.get('protocol','')).lower() == 'http', 'endpoint.protocol должен быть HTTP'
fields=e.get('expected_fields', e.get('fields', []))
assert {'progress','instance_id'} <= set(fields), 'endpoint должен перечислять progress и instance_id'
print('Модель состояния корректна')
PY
