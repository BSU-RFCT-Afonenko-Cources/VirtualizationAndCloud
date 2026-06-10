#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "Ошибка: $*" >&2; exit 1; }
docker volume inspect shop_db_data >/dev/null 2>&1 || fail "volume shop_db_data не существует"
mounts=$(docker service inspect shop_db --format '{{json .Spec.TaskTemplate.ContainerSpec.Mounts}}')
printf '%s' "$mounts" | grep -q 'shop_db_data' || fail "volume не подключён к db"
printf '%s' "$mounts" | grep -q '/home/ubuntu/shop/postgresql-data' || fail "неверный target PostgreSQL volume"
response=$(curl -fsS http://127.0.0.1:8080/api/products/swarm-book) || fail "товар swarm-book недоступен через API"
printf '%s' "$response" | grep -q '"name": "Swarm Book"' || fail "неверное название товара"
printf '%s' "$response" | grep -Eq '"price": [1-9][0-9]*' || fail "цена должна быть положительной"
count=$(docker service ps shop_db --no-trunc --format '{{.ID}}' | wc -l)
[ "$count" -ge 2 ] || fail "нет evidence пересоздания task db"
docker service ps shop_db --filter desired-state=running --format '{{.CurrentState}}' | grep -q '^Running' || fail "db task не running"
echo "Данные PostgreSQL сохранены в named volume"
