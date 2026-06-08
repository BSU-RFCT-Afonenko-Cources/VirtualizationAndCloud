#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
running() { docker service ps --filter desired-state=running --format '{{.CurrentState}}' "$1" | grep -c '^Running'; }
[ "$(running market_orders-api)" -ge 3 ] || fail "orders-api не имеет 3 running replicas"
[ "$(running market_catalog-api)" -ge 2 ] || fail "catalog-api не имеет 2 running replicas"
[ "$(docker service inspect --format '{{.Spec.EndpointSpec.Mode}}' market_orders-api)" = vip ] || fail "orders-api не использует VIP"
catalog=$(curl -fsS http://127.0.0.1:8080/catalog) || fail "Каталог недоступен через edge"
jq -e '.items|length>=2' <<<"$catalog" >/dev/null || fail "Некорректный каталог"
created=$(curl -fsS -X POST -H 'Content-Type: application/json' -d '{"item":"book","quantity":2}' http://127.0.0.1:8080/orders) || fail "Не удалось создать заказ"
id=$(jq -r '.id' <<<"$created"); [ -n "$id" ] && [ "$id" != null ] || fail "API не вернул order id"
jq -e --arg id "$id" '.id==$id and .item=="book" and .quantity==2' < <(curl -fsS "http://127.0.0.1:8080/orders/$id") >/dev/null || fail "Заказ не читается через edge"
echo "OK: replicas и HTTP workflow работают"
