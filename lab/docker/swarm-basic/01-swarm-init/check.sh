#!/usr/bin/env bash
set -euo pipefail
[ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = active ] || { echo 'Swarm is not active'; exit 1; }
[ "$(docker info --format '{{.Swarm.ControlAvailable}}')" = true ] || { echo 'The local node is not a manager'; exit 1; }
node_id="$(docker info --format '{{.Swarm.NodeID}}')"
[ -n "$node_id" ] && [ "$(docker node inspect --format '{{.Spec.Role}}' "$node_id")" = manager ] || { echo 'Manager role was not found'; exit 1; }
[ "$(docker node inspect --format '{{.Status.State}}' "$node_id")" = ready ] || { echo 'The manager node is not ready'; exit 1; }
echo 'Swarm is active; the local node is a ready manager.'
