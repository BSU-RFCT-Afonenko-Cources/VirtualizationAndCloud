#!/usr/bin/env bash
set -euo pipefail
if docker service inspect lab-worker >/dev/null 2>&1; then docker service rm lab-worker >/dev/null; fi
docker service create --quiet --name lab-worker --constraint 'node.labels.swarm_resources == true' --replicas 1 --reserve-cpu 0.25 --reserve-memory 128M swarm-resources-worker:lab >/dev/null
