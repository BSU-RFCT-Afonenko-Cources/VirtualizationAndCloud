#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "Ошибка: $*" >&2; exit 1; }
docker secret inspect shop_db_password_v1 >/dev/null 2>&1 || fail "secret shop_db_password_v1 не существует"
[ -f /home/ubuntu/shop/evidence/secret.json ] || fail "нет evidence/secret.json"
python3 - <<'PY' || exit 1
import json
from pathlib import Path
p=Path('/home/ubuntu/shop/evidence/secret.json')
try: data=json.loads(p.read_text())
except Exception as e: raise SystemExit(f'Ошибка: некорректный JSON: {e}')
expected={'secret':'shop_db_password_v1','delivery':'/run/secrets/db_password','plaintext_in_environment':False}
if set(data) != set(expected): raise SystemExit('Ошибка: evidence должен содержать только поля secret, delivery и plaintext_in_environment')
for k,v in expected.items():
    if data.get(k) != v: raise SystemExit(f'Ошибка: поле {k} должно быть {v!r}')
PY
STACK=/home/ubuntu/shop/stack.yml
[ -f "$STACK" ] || fail "нет stack.yml"
if grep -Eiq '(^|[[:space:]])(POSTGRES_PASSWORD|DB_PASSWORD):[[:space:]]*[^/[:space:]]' "$STACK"; then fail "пароль находится в environment"; fi
grep -q 'DB_PASSWORD_FILE: /run/secrets/db_password' "$STACK" || fail "API не использует secret-файл"
grep -q 'POSTGRES_PASSWORD_FILE: /run/secrets/db_password' "$STACK" || fail "PostgreSQL не использует secret-файл"
if find /home/ubuntu/shop -type f ! -name stack.yml ! -name secret.json -print0 | xargs -0 -r grep -IlE 'SwarmLab-DB|"password"[[:space:]]*:[[:space:]]*"[^"]+"' | grep -q .; then
  fail "в проекте найден похожий на plaintext пароль"
fi
for image in shop-api:v1 shop-api:v2; do
  docker image inspect "$image" >/dev/null 2>&1 || fail "нет подготовленного image $image"
  docker history --no-trunc "$image" | grep -Eiq 'SwarmLab-DB|POSTGRES_PASSWORD=' && fail "пароль обнаружен в history $image"
done
echo "Secret создан и plaintext не обнаружен"
