#!/bin/bash
set -euo pipefail
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" != active ]; then
  docker swarm init --advertise-addr 127.0.0.1 >/dev/null
fi
docker node update --availability active "$(docker info --format '{{.Swarm.NodeID}}')" >/dev/null
