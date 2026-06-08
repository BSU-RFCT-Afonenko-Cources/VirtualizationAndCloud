#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
FILE="$LAB/evidence/dns-error.txt"
test -s "$FILE" || { echo "Нет DNS evidence"; exit 1; }
grep -Eqi 'missing-api|host not found|resolve|upstream' "$FILE" || { echo "Нет маркера DNS/upstream ошибки"; exit 1; }
grep -Eq 'WEB_UPSTREAM:[[:space:]]+api:8080' "$LAB/compose.yaml" || { echo "WEB_UPSTREAM не исправлен"; exit 1; }
for service in web api db; do
  cid="$(docker compose -p web-api-db -f "$LAB/compose.yaml" ps -q "$service")"
  test "$(docker inspect -f '{{.State.Health.Status}}' "$cid")" = healthy || { echo "$service не healthy"; exit 1; }
done
curl --fail --silent --max-time 5 http://127.0.0.1:8080/api/items >/dev/null
