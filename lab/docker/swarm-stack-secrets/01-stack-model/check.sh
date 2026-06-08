#!/usr/bin/env bash
set -euo pipefail
STACK=/home/ubuntu/shop/stack.yml
fail(){ echo "Ошибка: $*" >&2; exit 1; }
[ -f "$STACK" ] || fail "не найден $STACK"
config=$(docker stack config -c "$STACK" 2>&1) || fail "stack.yml не проходит docker stack config: $config"
for service in web api db; do
  printf '%s\n' "$config" | grep -Eq "^  ${service}:$" || fail "нет service $service"
done
printf '%s\n' "$config" | grep -q 'shop-api:v1' || fail "api должен использовать shop-api:v1"
printf '%s\n' "$config" | grep -q 'nginx:1.27-alpine' || fail "не найден образ nginx"
printf '%s\n' "$config" | grep -q 'postgres:16-alpine' || fail "не найден образ postgres"
printf '%s\n' "$config" | grep -q 'published: 8080' || fail "web не публикует порт 8080"
printf '%s\n' "$config" | grep -q 'driver: overlay' || fail "backend не является overlay-сетью"
printf '%s\n' "$config" | grep -q 'name: shop_db_data' || fail "нет named volume shop_db_data"
for object in shop_db_password_v1 shop_nginx_v1 shop_api_config_v1; do
  grep -q "$object" "$STACK" || fail "нет ссылки на $object"
done
if grep -Eiq '(^|[[:space:]])(POSTGRES_PASSWORD|DB_PASSWORD):[[:space:]]*[^/[:space:]]' "$STACK"; then
  fail "пароль обнаружен в environment"
fi
for service in web api db; do
  section=$(printf '%s\n' "$config" | sed -n "/^  ${service}:/,/^  [a-zA-Z0-9_-]*:/p")
  printf '%s\n' "$section" | grep -q 'healthcheck:' || fail "у $service нет healthcheck"
  printf '%s\n' "$section" | grep -q 'restart_policy:' || fail "у $service нет restart policy"
  printf '%s\n' "$section" | grep -q 'update_config:' || fail "у $service нет update policy"
done
echo "Stack model корректен"
