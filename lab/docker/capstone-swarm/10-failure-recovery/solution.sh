#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
old_task=$(docker service ps --filter desired-state=running --format '{{.ID}}' market_catalog-api | head -1)
container=$(docker ps --filter label=com.docker.swarm.task.id="$old_task" --format '{{.ID}}' | head -1)
[ -n "$container" ] || { echo "Контейнер task не найден" >&2; exit 1; }
docker rm -f "$container" >/dev/null
new_task=
for _ in $(seq 1 90); do
  new_task=$(docker service ps --filter desired-state=running --format '{{.ID}}' market_catalog-api | grep -v "^$old_task$" | head -1)
  [ -n "$new_task" ] && [ "$(docker service ls --filter name=market_catalog-api --format '{{.Replicas}}')" = 2/2 ] && curl -fsS http://127.0.0.1:8080/catalog >/dev/null 2>&1 && break
  sleep 2
done
[ -n "$new_task" ] || { echo "Replacement task не создана" >&2; exit 1; }
jq -n --arg service market_catalog-api --arg old_task "$old_task" --arg new_task "$new_task" '{service:$service,removed_task:$old_task,replacement_task:$new_task,recovered:true}' > /home/ubuntu/capstone-swarm/evidence/recovery.json
chown ubuntu:ubuntu /home/ubuntu/capstone-swarm/evidence/recovery.json
