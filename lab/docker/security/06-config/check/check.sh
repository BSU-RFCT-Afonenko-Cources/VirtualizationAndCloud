#!/bin/bash
set -euo pipefail
WORKDIR=/home/ubuntu/docker-security
ENVFILE="$WORKDIR/app.env"
[ -f "$ENVFILE" ] || { echo "Отсутствует $ENVFILE"; exit 1; }
[ "$(grep -Ec '^APP_ENDPOINT=/api/security$' "$ENVFILE")" -eq 1 ] || { echo "Некорректный APP_ENDPOINT"; exit 1; }
[ "$(grep -Ec '^APP_VERSION=1\.0\.0$' "$ENVFILE")" -eq 1 ] || { echo "Некорректный APP_VERSION"; exit 1; }
IMAGE_ENV=$(docker image inspect -f '{{json .Config.Env}}' security-api:lab)
[[ "$IMAGE_ENV" != *'/api/security'* && "$IMAGE_ENV" != *'1.0.0'* ]] || { echo "Runtime-конфигурация обнаружена в переменных образа"; exit 1; }
SAVED=$(mktemp -d)
trap 'rm -rf "$SAVED"' EXIT
docker image save security-api:lab -o "$SAVED/image.tar"
if tar -xOf "$SAVED/image.tar" 2>/dev/null | strings | grep -Fq '/api/security'; then
  echo "Endpoint обнаружен в файловых слоях образа"; exit 1
fi
python3 - <<'PY'
import json, urllib.request
with urllib.request.urlopen('http://127.0.0.1:18080/api/security', timeout=3) as response:
    payload = json.load(response)
if payload.get('version') != '1.0.0':
    raise SystemExit('API вернул неверную версию')
print('Runtime-конфигурация отделена от образа')
PY
