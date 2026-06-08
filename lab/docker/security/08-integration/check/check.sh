#!/bin/bash
set -euo pipefail
CONTAINER=security-api
SECRET_FILE=/home/ubuntu/docker-security/runtime/secret/db_password
INSPECT=$(docker inspect "$CONTAINER" 2>/dev/null) || { echo "Контейнер $CONTAINER не найден"; exit 1; }
python3 - "$INSPECT" <<'PY'
import json, sys
c = json.loads(sys.argv[1])[0]
h = c['HostConfig']
errors = []
if c['State'].get('Status') != 'running': errors.append('container is not running')
if c['State'].get('Health', {}).get('Status') != 'healthy': errors.append('health status is not healthy')
if c['Config'].get('User') != '10001:10001': errors.append('user is not 10001:10001')
if not h.get('ReadonlyRootfs'): errors.append('rootfs is not read-only')
if set(h.get('CapDrop') or []) != {'ALL'} or h.get('CapAdd'): errors.append('capabilities are not minimal')
opts = h.get('SecurityOpt') or []
if 'no-new-privileges:true' not in opts: errors.append('no-new-privileges is absent')
if any('seccomp' in x and 'unconfined' in x for x in opts): errors.append('seccomp is unconfined')
if h.get('RestartPolicy', {}).get('Name') != 'unless-stopped': errors.append('restart policy is not unless-stopped')
tmpfs = h.get('Tmpfs', {}).get('/var/lib/hardened-api', '')
for option in ('rw','noexec','nosuid','nodev','uid=10001','gid=10001'):
    if option not in tmpfs.split(','): errors.append(f'tmpfs misses {option}')
ports = c['NetworkSettings']['Ports'].get('8080/tcp') or []
if len(ports) != 1 or ports[0] != {'HostIp':'127.0.0.1','HostPort':'18080'}: errors.append('published port is not loopback-only 18080')
mounts = [m for m in c['Mounts'] if m['Destination'] == '/run/secrets/db_password']
if len(mounts) != 1 or mounts[0]['RW']: errors.append('secret mount is absent or writable')
if errors: raise SystemExit('; '.join(errors))
PY
SECRET=$(cat "$SECRET_FILE")
LOGS=$(docker logs "$CONTAINER" 2>&1)
[[ "$LOGS" != *"$SECRET"* ]] || { echo "Секрет обнаружен в логах"; exit 1; }
python3 - "$SECRET" <<'PY'
import json, sys, urllib.request
secret = sys.argv[1]
with urllib.request.urlopen('http://127.0.0.1:18080/health', timeout=3) as response:
    health = json.load(response)
with urllib.request.urlopen('http://127.0.0.1:18080/api/security', timeout=3) as response:
    payload = json.load(response)
if health != {'status': 'ok'}:
    raise SystemExit('Некорректный health response')
if payload.get('service') != 'hardened-api' or payload.get('version') != '1.0.0':
    raise SystemExit('Некорректная идентификация API')
if payload.get('secret_loaded') is not True or not isinstance(payload.get('request_count'), int):
    raise SystemExit('API не загрузил секрет или не обновил счётчик')
if secret in json.dumps(payload):
    raise SystemExit('API раскрыл значение секрета')
print('Итоговый hardened-контейнер прошёл HTTP smoke-test')
PY
