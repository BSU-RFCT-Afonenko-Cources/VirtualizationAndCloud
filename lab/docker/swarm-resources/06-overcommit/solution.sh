#!/usr/bin/env bash
set -euo pipefail
EVIDENCE=/home/ubuntu/swarm-resources/evidence/overcommit-pending.json
if docker service inspect lab-overcommit >/dev/null 2>&1; then docker service rm lab-overcommit >/dev/null; fi
docker service create --quiet --name lab-overcommit --constraint 'node.labels.swarm_resources == true' --replicas 1 --reserve-cpu 1000 --reserve-memory 1T swarm-resources-worker:lab >/dev/null

timeout 30 bash -c 'until docker service ps lab-overcommit --no-trunc --format "{{.CurrentState}} {{.Error}}" | grep -qi "Pending.*insufficient resources"; do sleep 1; done'
line=$(docker service ps lab-overcommit --no-trunc --format '{{json .}}' | head -n1)
printf '%s\n' "$line" | jq '{service: "lab-overcommit", desired_state: .DesiredState, current_state: .CurrentState, error: .Error}' > "$EVIDENCE"
chown ubuntu:ubuntu "$EVIDENCE"
docker service update --quiet --reserve-cpu 0.05 --reserve-memory 32M lab-overcommit >/dev/null
