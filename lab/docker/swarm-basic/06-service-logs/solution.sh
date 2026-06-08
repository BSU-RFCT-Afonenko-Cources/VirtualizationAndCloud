#!/usr/bin/env bash
set -euo pipefail
EVIDENCE=/home/ubuntu/swarm-basic/service-logs.txt
mkdir -p /home/ubuntu/swarm-basic
for request in 1 2 3; do
  curl --fail --silent --max-time 5 "http://127.0.0.1:8080/health" >/dev/null
done
sleep 1
docker service logs --timestamps lab-api > "$EVIDENCE" 2>&1
chown ubuntu:ubuntu "$EVIDENCE"
