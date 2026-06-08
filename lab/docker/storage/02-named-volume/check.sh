#!/bin/bash
set -euo pipefail
mountpoint=$(/usr/bin/docker volume inspect --format '{{.Mountpoint}}' lab-data)
[ -n "$mountpoint" ] && [ -d "$mountpoint" ] || { /usr/bin/echo 'Volume lab-data не имеет доступного mountpoint'; exit 1; }
[ "$(/usr/bin/docker volume inspect --format '{{index .Labels "course.lab"}}' lab-data)" = storage ] || { /usr/bin/echo 'У volume отсутствует label course.lab=storage'; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.State.Running}}' storage-db)" = true ] || { /usr/bin/echo 'storage-db не запущен'; exit 1; }
/usr/bin/python3 - <<'PYDOCKER'
import json, subprocess
info = json.loads(subprocess.check_output(['/usr/bin/docker', 'inspect', 'storage-db']))[0]
mounts = [m for m in info['Mounts'] if m['Destination'] == '/data']
assert len(mounts) == 1, 'нет единственного mount в /data'
mount = mounts[0]
assert mount['Type'] == 'volume', 'в /data подключён не volume'
assert mount['Name'] == 'lab-data', 'подключён неверный volume'
assert mount['RW'] is True, 'volume должен быть writable'
PYDOCKER
