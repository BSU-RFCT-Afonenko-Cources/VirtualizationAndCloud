#!/bin/bash
set -euo pipefail
/usr/bin/python3 - <<'PYJSON'
import json
from pathlib import Path
before = json.loads(Path('/home/ubuntu/storage/evidence/ephemeral-before.json').read_text())
after = json.loads(Path('/home/ubuntu/storage/evidence/ephemeral-after.json').read_text())
assert before.get('marker_present') is True, 'evidence до не подтверждает наличие marker'
assert before.get('marker') == 'writable-layer-data', 'неверное значение marker'
assert after.get('marker_present') is False, 'evidence после не подтверждает потерю marker'
assert before.get('container_id') and after.get('container_id'), 'не записаны container_id'
assert before['container_id'] != after['container_id'], 'контейнер не был пересоздан'
PYJSON
current_id=$(/usr/bin/docker inspect --format '{{.Id}}' storage-ephemeral)
after_id=$(/usr/bin/python3 -c 'import json; print(json.load(open("/home/ubuntu/storage/evidence/ephemeral-after.json"))["container_id"])')
[ "$current_id" = "$after_id" ] || { /usr/bin/echo 'Запущен не тот контейнер, который указан в evidence после'; exit 1; }
if /usr/bin/docker exec storage-ephemeral /usr/bin/test -e /tmp/ephemeral-marker; then
  /usr/bin/echo 'Marker сохранился в новом writable layer'
  exit 1
fi
[ "$(/usr/bin/docker inspect --format '{{range .Mounts}}{{.Destination}}{{end}}' storage-ephemeral)" = '' ] || { /usr/bin/echo 'У ephemeral-контейнера не должно быть mounts'; exit 1; }
