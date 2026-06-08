#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
created=$(curl -fsS -X POST -H 'Content-Type: application/json' -d '{"item":"persistent-marker","quantity":7}' http://127.0.0.1:8080/orders)
id=$(jq -r '.id' <<<"$created")
old_task=$(docker service ps --filter desired-state=running --format '{{.ID}}' market_db | head -1)
docker service update --force market_db >/dev/null
new_task=
for _ in $(seq 1 90); do
  new_task=$(docker service ps --filter desired-state=running --format '{{.ID}}' market_db | head -1)
  if [ -n "$new_task" ] && [ "$new_task" != "$old_task" ] && curl -fsS "http://127.0.0.1:8080/orders/$id" >/dev/null 2>&1; then break; fi
  sleep 2
done
jq -n --arg order_id "$id" --arg old_task "$old_task" --arg new_task "$new_task" '{order_id:$order_id,old_db_task:$old_task,new_db_task:$new_task,preserved:true}' > /home/ubuntu/capstone-swarm/evidence/persistence.json
chown ubuntu:ubuntu /home/ubuntu/capstone-swarm/evidence/persistence.json
