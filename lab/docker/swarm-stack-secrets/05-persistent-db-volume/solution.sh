#!/usr/bin/env bash
set -euo pipefail
for _ in $(seq 1 60); do
  if curl -fsS http://127.0.0.1:8080/api/health >/dev/null 2>&1; then break; fi
  sleep 2
done
curl -fsS -X POST http://127.0.0.1:8080/api/products \
  -H 'Content-Type: application/json' \
  -d '{"code":"swarm-book","name":"Swarm Book","price":42}' >/dev/null
old=$(docker service ps shop_db --filter desired-state=running --format '{{.ID}}' | head -n 1)
docker service update --force shop_db >/dev/null
for _ in $(seq 1 90); do
  new=$(docker service ps shop_db --filter desired-state=running --format '{{.ID}}' | head -n 1)
  if [ -n "$new" ] && [ "$new" != "$old" ] && curl -fsS http://127.0.0.1:8080/api/products/swarm-book | grep -q 'Swarm Book'; then
    exit 0
  fi
  sleep 2
done
exit 1
