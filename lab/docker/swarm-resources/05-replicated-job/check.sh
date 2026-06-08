#!/usr/bin/env bash
set -euo pipefail
mode=$(docker service inspect lab-worker-job --format '{{json .Spec.Mode.ReplicatedJob}}')
[ "$mode" != null ]
timeout 60 bash -c 'until [ "$(docker service ps lab-worker-job --format "{{.CurrentState}}" | awk '\''$1 == "Complete" {n++} END {print n+0}'\'')" -eq 3 ]; do sleep 1; done'
for slot in 1 2 3; do
    file="/home/ubuntu/swarm-resources/results/worker-${slot}.json"
    [ -f "$file" ]
    jq -e --arg slot "$slot" '.service == "lab-worker-job" and .task_slot == $slot and (.task_id | length > 5) and .records_processed == (1000 + ($slot | tonumber))' "$file" >/dev/null
done
log_count=$(docker service logs lab-worker-job 2>&1 | grep -c '"service": "lab-worker-job"' || true)
[ "$log_count" -ge 3 ] || { echo "в логах недостаточно результатов job" >&2; exit 1; }
echo "replicated job, логи и три JSON-результата проверены"
