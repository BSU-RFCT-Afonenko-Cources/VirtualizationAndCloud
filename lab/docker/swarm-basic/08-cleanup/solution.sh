#!/usr/bin/env bash
set -euo pipefail
if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = active ]; then
  docker service ls --format '{{.Name}}' | awk '/^lab-/' | xargs --no-run-if-empty docker service rm
  for attempt in $(seq 1 30); do
    remaining="$(docker ps --all --filter label=com.docker.swarm.service.name=lab-api --format '{{.ID}}')"
    [ -z "$remaining" ] && exit 0
    sleep 1
  done
  exit 1
fi
