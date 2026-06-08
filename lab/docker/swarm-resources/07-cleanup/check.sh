#!/usr/bin/env bash
set -euo pipefail
for service in lab-api lab-worker lab-worker-job lab-overcommit; do
    if docker service inspect "$service" >/dev/null 2>&1; then
        echo "service $service всё ещё существует" >&2
        exit 1
    fi
done
value=$(docker node inspect self --format '{{ index .Spec.Labels "swarm_resources" }}')
[ -z "$value" ] || { echo "label swarm_resources не удалён" >&2; exit 1; }
[ -f /home/ubuntu/swarm-resources/evidence/overcommit-pending.json ]
for slot in 1 2 3; do [ -f "/home/ubuntu/swarm-resources/results/worker-${slot}.json" ]; done
echo "services и lab label удалены; evidence сохранены"
