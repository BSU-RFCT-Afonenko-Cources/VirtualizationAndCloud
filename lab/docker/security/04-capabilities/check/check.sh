#!/bin/bash
set -euo pipefail
CONTAINER=security-api
INSPECT=$(docker inspect "$CONTAINER" 2>/dev/null) || { echo "Контейнер $CONTAINER не найден"; exit 1; }
python3 - "$INSPECT" <<'PY'
import json, sys
container = json.loads(sys.argv[1])[0]
host = container['HostConfig']
if set(host.get('CapDrop') or []) != {'ALL'}:
    raise SystemExit('Должны быть удалены все capabilities')
if host.get('CapAdd'):
    raise SystemExit('CapAdd должен оставаться пустым')
opts = host.get('SecurityOpt') or []
if 'no-new-privileges:true' not in opts:
    raise SystemExit('Не включён no-new-privileges')
if any(opt in {'seccomp=unconfined', 'seccomp:unconfined'} for opt in opts):
    raise SystemExit('Стандартный seccomp-профиль отключён')
PY
python3 -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:18080/health', timeout=3)" >/dev/null
echo "Capabilities удалены, повышение привилегий запрещено"
