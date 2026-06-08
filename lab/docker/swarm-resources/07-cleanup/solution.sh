#!/usr/bin/env bash
set -euo pipefail
for service in lab-api lab-worker lab-worker-job lab-overcommit; do
    if docker service inspect "$service" >/dev/null 2>&1; then
        docker service rm "$service" >/dev/null
    fi
done
manager_id=$(docker node inspect self --format '{{.ID}}')
docker node update --label-rm swarm_resources "$manager_id" >/dev/null
