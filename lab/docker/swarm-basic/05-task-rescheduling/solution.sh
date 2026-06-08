#!/usr/bin/env bash
set -euo pipefail
BASELINE=/var/lib/swarm-basic-task-before.txt
if [ ! -s "$BASELINE" ]; then
  docker service ps --filter desired-state=running --format '{{.ID}}' lab-api | sort > "$BASELINE"
fi
container_id="$(docker ps --filter label=com.docker.swarm.service.name=lab-api --format '{{.ID}}' | head -n 1)"
[ -n "$container_id" ] || { echo 'No lab-api task container found'; exit 1; }
docker rm --force "$container_id"
for attempt in $(seq 1 45); do
  docker service ps --filter desired-state=running --format '{{.ID}}' lab-api | sort > /tmp/swarm-basic-task-solution.txt
  running="$(docker service ps --filter desired-state=running --format '{{.CurrentState}}' lab-api | awk '$1 == "Running" {count++} END {print count+0}')"
  if [ "$running" -eq 3 ] && ! cmp --silent "$BASELINE" /tmp/swarm-basic-task-solution.txt; then
    exit 0
  fi
  sleep 1
done
exit 1
