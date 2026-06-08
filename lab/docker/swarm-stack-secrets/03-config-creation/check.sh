#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "Ошибка: $*" >&2; exit 1; }
for object in shop_nginx_v1 shop_api_config_v1; do docker config inspect "$object" >/dev/null 2>&1 || fail "config $object не существует"; done
python3 - <<'PY' || exit 1
import base64,json,subprocess

def data(name):
    raw=subprocess.check_output(['docker','config','inspect',name,'--format','{{json .Spec.Data}}'], text=True).strip()
    return base64.b64decode(json.loads(raw)).decode()
ng=data('shop_nginx_v1')
if 'listen 80' not in ng or 'location /api/' not in ng or 'proxy_pass http://api:8000/' not in ng or 'location = /health' not in ng:
    raise SystemExit('Ошибка: nginx config не описывает требуемые endpoints/proxy')
try: api=json.loads(data('shop_api_config_v1'))
except Exception as e: raise SystemExit(f'Ошибка: API config не является JSON: {e}')
if api.get('app')!='shop' or api.get('version')!='v1': raise SystemExit('Ошибка: неверные app/version в API config')
PY
STACK=/home/ubuntu/shop/stack.yml
grep -q 'target: /etc/nginx/conf.d/default.conf' "$STACK" || fail "nginx config не подключён к требуемому target"
grep -q 'target: /app/config.json' "$STACK" || fail "API config не подключён к требуемому target"
echo "Configs созданы и подключены в модели"
