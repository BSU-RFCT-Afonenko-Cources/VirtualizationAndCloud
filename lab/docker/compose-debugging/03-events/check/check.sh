#!/bin/bash
set -euo pipefail
FILE=/home/ubuntu/compose-debugging/evidence/api-events.jsonl
test -s "$FILE" || { echo "Нет events evidence"; exit 1; }
python3 - "$FILE" <<'PY'
import json,sys
rows=[json.loads(line) for line in open(sys.argv[1]) if line.strip()]
actions={r.get('Action') or r.get('status') for r in rows}
assert 'start' in actions, 'Нет события start'
assert actions & {'stop','die','kill','restart'}, 'Нет события остановки/restart'
assert any('api' in json.dumps(r).lower() for r in rows), 'Нет маркера сервиса api'
assert all(r.get('time') or r.get('timeNano') for r in rows), 'Нет временной метки'
PY
