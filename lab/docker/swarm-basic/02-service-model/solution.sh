#!/usr/bin/env bash
set -euo pipefail
if docker service inspect lab-api >/dev/null 2>&1; then
  docker service update --image swarm-api:lab --replicas 1 lab-api
else
  docker service create --detach=true --name lab-api --replicas 1 swarm-api:lab
fi
docker service update --publish-rm 8000 lab-api >/dev/null 2>&1 || true
for attempt in $(seq 1 30); do
  running="$(docker service ps --filter desired-state=running --format '{{.CurrentState}}' lab-api | awk '$1 == "Running" {count++} END {print count+0}')"
  [ "$running" -eq 1 ] && exit 0
  sleep 1
done
docker service ps lab-api
exit 1
