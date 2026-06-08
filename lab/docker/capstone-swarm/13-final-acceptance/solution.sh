#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
for _ in $(seq 1 120); do
  ready=true
  while read -r replicas; do [ "${replicas%/*}" = "${replicas#*/}" ] || ready=false; done < <(docker service ls --filter label=com.docker.stack.namespace=market --format '{{.Replicas}}')
  if $ready && curl -fsS http://127.0.0.1:8080/health >/dev/null 2>&1; then break; fi
  sleep 2
done
curl -fsS -X POST -H 'Content-Type: application/json' -d '{"item":"final-acceptance","quantity":1}' http://127.0.0.1:8080/orders > /home/ubuntu/capstone-swarm/evidence/final-order.json
chown ubuntu:ubuntu /home/ubuntu/capstone-swarm/evidence/final-order.json
