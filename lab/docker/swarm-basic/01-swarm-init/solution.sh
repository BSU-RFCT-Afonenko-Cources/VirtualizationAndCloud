#!/usr/bin/env bash
set -euo pipefail
state="$(docker info --format '{{.Swarm.LocalNodeState}}')"
if [ "$state" != active ]; then
  advertise_address="$(hostname -I | awk '{print $1}')"
  docker swarm init --advertise-addr "$advertise_address"
fi
