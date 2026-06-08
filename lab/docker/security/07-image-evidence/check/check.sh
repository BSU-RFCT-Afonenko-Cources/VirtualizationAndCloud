#!/bin/bash
set -euo pipefail
FILE=/home/ubuntu/docker-security/image-evidence.json
[ -f "$FILE" ] || { echo "Отсутствует $FILE"; exit 1; }
python3 - <<'PY'
import json, re, subprocess
from pathlib import Path
data = json.loads(Path('/home/ubuntu/docker-security/image-evidence.json').read_text())
expected = {
    'base_image': 'python:3.13-alpine',
    'application_image': 'security-api:lab',
    'application_version': '1.0.0',
    'scan_status': 'local-metadata-checked',
}
for key, value in expected.items():
    if data.get(key) != value:
        raise SystemExit(f'Некорректное поле {key}')
digest = data.get('base_digest', '')
if not re.fullmatch(r'sha256:[0-9a-f]{64}', digest):
    raise SystemExit('base_digest должен иметь формат sha256:<64 hex>')
base = json.loads(subprocess.check_output(['docker','image','inspect','python:3.13-alpine']))[0]
valid = {base['Id']} | {item.split('@', 1)[1] for item in base.get('RepoDigests', []) if '@' in item}
if digest not in valid:
    raise SystemExit('Digest не соответствует локальному базовому образу')
labels = json.loads(subprocess.check_output(['docker','image','inspect','security-api:lab']))[0]['Config'].get('Labels') or {}
required = {
    'org.opencontainers.image.title': 'hardened-api',
    'org.opencontainers.image.version': '1.0.0',
    'org.opencontainers.image.base.name': 'python:3.13-alpine',
}
for key, value in required.items():
    if labels.get(key) != value:
        raise SystemExit(f'Отсутствует OCI label {key}={value}')
print('Evidence соответствует локальным образам и OCI labels')
PY
