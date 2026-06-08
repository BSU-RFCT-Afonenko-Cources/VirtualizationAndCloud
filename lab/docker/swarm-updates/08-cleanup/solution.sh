#!/usr/bin/env bash
set -euo pipefail

docker service rm orders-api >/dev/null 2>&1 || true
for _ in $(seq 1 30); do
  containers=$(docker ps -aq --filter 'label=com.docker.swarm.service.name=orders-api')
  [ -z "$containers" ] && break
  sleep 1
done
containers=$(docker ps -aq --filter 'label=com.docker.swarm.service.name=orders-api')
if [ -n "$containers" ]; then
  docker rm -f $containers >/dev/null
fi
docker image rm orders-api:v1 orders-api:v2 orders-api:bad >/dev/null 2>&1 || true
