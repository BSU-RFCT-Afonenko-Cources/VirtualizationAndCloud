#!/bin/bash
set -euo pipefail
FILE=/home/ubuntu/compose-debugging/evidence/stats.jsonl
test -s "$FILE" || { echo "Нет stats evidence"; exit 1; }
python3 - "$FILE" <<'PY'
import json,sys
rows=[json.loads(line) for line in open(sys.argv[1]) if line.strip()]
for service in ('web','api','db'):
    matches=[r for r in rows if service in (r.get('Name','')+' '+r.get('Container','')).lower()]
    assert matches, f'Нет метрик {service}'
    r=matches[0]
    assert r.get('CPUPerc') or r.get('CPU %'), f'Нет CPU для {service}'
    assert r.get('MemUsage') or r.get('MemUsage / Limit'), f'Нет memory для {service}'
    assert r.get('NetIO') or r.get('Net I/O'), f'Нет network I/O для {service}'
PY
