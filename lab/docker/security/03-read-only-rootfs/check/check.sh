#!/bin/bash
set -euo pipefail
CONTAINER=security-api
[ "$(docker inspect -f '{{.HostConfig.ReadonlyRootfs}}' "$CONTAINER" 2>/dev/null)" = true ] || { echo "Root filesystem не переведена в read-only"; exit 1; }
TMPFS=$(docker inspect -f '{{index .HostConfig.Tmpfs "/home/ubuntu/docker-security/state"}}' "$CONTAINER")
for option in rw noexec nosuid nodev uid=10001 gid=10001; do
  [[ ",$TMPFS," == *",$option,"* ]] || { echo "Для tmpfs отсутствует параметр $option"; exit 1; }
done
if docker exec "$CONTAINER" python -c "open('/home/ubuntu/docker-security/app/probe','w')" >/dev/null 2>&1; then
  echo "Запись в rootfs неожиданно разрешена"; exit 1
fi
docker exec "$CONTAINER" python -c "open('/home/ubuntu/docker-security/state/probe','w').write('ok')"
python3 - <<'PY'
import json, urllib.request
for path in ('/health', '/api/status'):
    with urllib.request.urlopen('http://127.0.0.1:18080' + path, timeout=3) as response:
        json.load(response)
print('Read-only rootfs и выделенный writable tmpfs работают')
PY
