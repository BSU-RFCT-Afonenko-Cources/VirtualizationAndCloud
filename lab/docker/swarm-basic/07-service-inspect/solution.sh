#!/usr/bin/env bash
set -euo pipefail
EVIDENCE=/home/ubuntu/swarm-basic/lab-api-inspect.json
mkdir -p /home/ubuntu/swarm-basic
docker service inspect lab-api > "$EVIDENCE"
chown ubuntu:ubuntu "$EVIDENCE"
