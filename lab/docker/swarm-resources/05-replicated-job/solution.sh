#!/usr/bin/env bash
set -euo pipefail
rm -f /home/ubuntu/swarm-resources/results/worker-*.json
if docker service inspect lab-worker-job >/dev/null 2>&1; then docker service rm lab-worker-job >/dev/null; fi
docker service create --quiet --name lab-worker-job --mode replicated-job --replicas 3 --max-concurrent 1 --constraint 'node.labels.swarm_resources == true' --env 'TASK_SLOT={{.Task.Slot}}' --env 'TASK_ID={{.Task.ID}}' --mount type=bind,src=/home/ubuntu/swarm-resources/results,dst=/results swarm-resources-worker:lab job >/dev/null
