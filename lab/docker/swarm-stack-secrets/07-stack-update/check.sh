#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "Ошибка: $*" >&2; exit 1; }
image=$(docker service inspect shop_api --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}')
printf '%s' "$image" | grep -q '^shop-api:v2' || fail "shop_api не использует image v2"
docker service inspect shop_api --format '{{range .Spec.TaskTemplate.ContainerSpec.Configs}}{{println .ConfigName}}{{end}}' | grep -qx shop_api_config_v3 || fail "shop_api не использует config v3"
version=$(curl -fsS http://127.0.0.1:8080/api/version) || fail "version endpoint недоступен"
printf '%s' "$version" | grep -q '"version": "v2"' || fail "config version не v2"
printf '%s' "$version" | grep -q '"image": "v2"' || fail "фактический API image не v2"
for service in web api db; do
  [ "$(docker service ls --filter name="shop_$service" --format '{{.Replicas}}')" = '1/1' ] || fail "shop_$service не достиг 1/1"
done
state=$(docker service inspect shop_api --format '{{if .UpdateStatus}}{{.UpdateStatus.State}}{{else}}none{{end}}')
[ "$state" = completed ] || fail "rolling update state=$state, ожидалось completed"
curl -fsS http://127.0.0.1:8080/api/products/swarm-book | grep -q 'Swarm Book' || fail "данные не сохранились после update"
echo "Stack обновлён до API v2"
