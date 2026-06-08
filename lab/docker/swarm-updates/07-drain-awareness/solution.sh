#!/usr/bin/env bash
set -euo pipefail
EVIDENCE=/home/ubuntu/swarm-updates/evidence/node-awareness.json
NODE_ID=$(docker info --format '{{.Swarm.NodeID}}')

docker node update --availability active "$NODE_ID" >/dev/null
current_constraints=$(docker service inspect --format '{{json .Spec.TaskTemplate.Placement.Constraints}}' orders-api)
if ! jq -e 'index("node.role == manager") != null' <<<"$current_constraints" >/dev/null; then
  docker service update --constraint-add 'node.role == manager' --detach=false orders-api >/dev/null
fi

node_json=$(docker node inspect "$NODE_ID")
constraints=$(docker service inspect --format '{{json .Spec.TaskTemplate.Placement.Constraints}}' orders-api)
jq -n \
  --arg node_id "$(jq -r '.[0].ID' <<<"$node_json")" \
  --arg hostname "$(jq -r '.[0].Description.Hostname' <<<"$node_json")" \
  --arg availability "$(jq -r '.[0].Spec.Availability' <<<"$node_json")" \
  --arg manager_status "$(jq -r '.[0].ManagerStatus.Reachability // "none"' <<<"$node_json")" \
  --argjson constraints "$constraints" \
  '{node_id:$node_id, hostname:$hostname, availability:$availability, manager_status:$manager_status, service_constraints:$constraints}' \
  > "$EVIDENCE"
chown ubuntu:ubuntu "$EVIDENCE"
