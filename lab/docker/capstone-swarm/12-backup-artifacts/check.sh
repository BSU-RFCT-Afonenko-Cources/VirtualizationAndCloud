#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
backup=/home/ubuntu/capstone-swarm/backup
for file in market-stack.yml secrets-inventory.json configs/market_edge_routes configs/market_api_config market.sql SHA256SUMS; do [ -s "$backup/$file" ] || fail "Нет backup/$file"; done
jq -e 'type=="array" and any(.[]; .name=="market_db_password") and all(.[]; (has("value")|not) and (has("data")|not))' "$backup/secrets-inventory.json" >/dev/null || fail "Secret inventory неверен или содержит значения"
! grep -q 'swarm-capstone-db-2026' "$backup/secrets-inventory.json" || fail "Inventory содержит secret value"
grep -Eq 'CREATE TABLE public.orders|COPY public.orders' "$backup/market.sql" || fail "SQL dump не содержит orders"
(cd "$backup" && sha256sum -c /home/ubuntu/capstone-swarm/backup/SHA256SUMS) >/dev/null || fail "Checksum не совпадает"
echo "OK: backup artifacts полны и проверены"
