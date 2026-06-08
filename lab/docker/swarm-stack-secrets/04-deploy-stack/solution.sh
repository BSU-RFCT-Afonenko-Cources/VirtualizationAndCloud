#!/usr/bin/env bash
set -euo pipefail
docker stack deploy -c /home/ubuntu/shop/stack.yml shop >/dev/null
for _ in $(seq 1 90); do
  running=$(docker service ls --filter label=com.docker.stack.namespace=shop --format '{{.Name}} {{.Replicas}}' | awk '$2=="1/1"{c++} END{print c+0}')
  if [ "$running" -eq 3 ] && curl -fsS http://127.0.0.1:8080/health >/dev/null 2>&1; then
    exit 0
  fi
  sleep 2
done
docker service ls --filter label=com.docker.stack.namespace=shop
exit 1
