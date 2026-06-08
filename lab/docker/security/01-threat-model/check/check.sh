#!/bin/bash
set -euo pipefail
FILE=/home/ubuntu/docker-security/threat-model.json
[ -f "$FILE" ] || { echo "Отсутствует $FILE"; exit 1; }
python3 - <<'PY'
import json
from pathlib import Path
path = Path('/home/ubuntu/docker-security/threat-model.json')
try:
    data = json.loads(path.read_text())
except (OSError, json.JSONDecodeError) as exc:
    raise SystemExit(f'Некорректный JSON: {exc}')
risks = data.get('risks')
if not isinstance(risks, list):
    raise SystemExit('Поле risks должно быть массивом')
required = {'root-user', 'writable-rootfs', 'capabilities', 'secret-in-image'}
fields = {'category', 'asset', 'threat', 'impact', 'mitigation'}
for risk in risks:
    if not isinstance(risk, dict) or any(not isinstance(risk.get(k), str) or not risk[k].strip() for k in fields):
        raise SystemExit('Каждый риск должен содержать непустые строковые поля category, asset, threat, impact, mitigation')
categories = [risk['category'] for risk in risks]
if not required.issubset(categories):
    raise SystemExit('Не описаны обязательные категории: ' + ', '.join(sorted(required - set(categories))))
if len(categories) != len(set(categories)):
    raise SystemExit('Категории рисков должны быть уникальными')
print('Модель угроз содержит все обязательные категории')
PY
