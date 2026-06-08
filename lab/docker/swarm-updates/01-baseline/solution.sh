#!/usr/bin/env bash
set -euo pipefail

docker service rm orders-api >/dev/null 2>&1 || true
while docker service inspect orders-api >/dev/null 2>&1; do sleep 1; done

docker service create \
  --name orders-api \
  --replicas 3 \
  --publish published=18080,target=8080,mode=ingress \
  --health-cmd 'python -c "import urllib.request; urllib.request.urlopen(\"http://127.0.0.1:8080/health\", timeout=2)"' \
  --health-interval 5s \
  --health-timeout 3s \
  --health-retries 2 \
  --health-start-period 3s \
  orders-api:v1 >/dev/null

docker service update --detach=false orders-api >/dev/null
