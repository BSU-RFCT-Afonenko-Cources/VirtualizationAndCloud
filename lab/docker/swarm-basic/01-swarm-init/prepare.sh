#!/usr/bin/env bash
set -euo pipefail
LAB_DIR=/home/ubuntu/swarm-basic
STUDENT_DIR=/home/ubuntu/swarm-basic
ASSET_DIR=/home/ubuntu/swarm-basic/image
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
rm -rf "$LAB_DIR"
mkdir -p "$ASSET_DIR" "$STUDENT_DIR"
install -m 0644 "$SCRIPT_DIR/../assets/Dockerfile" "$ASSET_DIR/Dockerfile"
install -m 0644 "$SCRIPT_DIR/../assets/swarm_api.py" "$ASSET_DIR/swarm_api.py"
chown -R ubuntu:ubuntu "$STUDENT_DIR"
docker build --pull=false --tag swarm-api:lab "$ASSET_DIR"
if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = active ]; then
  docker service ls --format '{{.Name}}' | awk '/^lab-/' | xargs --no-run-if-empty docker service rm
fi
rm -f /home/ubuntu/swarm-basic/swarm-basic-task-before.txt
