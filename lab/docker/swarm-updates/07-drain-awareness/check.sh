#!/usr/bin/env bash
set -euo pipefail
EVIDENCE=/home/ubuntu/swarm-updates/evidence/node-awareness.json
fail() { echo "Ошибка: $*" >&2; exit 1; }
node_id=$(docker info --format '{{.Swarm.NodeID}}')
node_json=$(docker node inspect "$node_id" 2>/dev/null) || fail "локальный Swarm node не найден"
[ "$(jq -r '.[0].Spec.Availability' <<<"$node_json")" = "active" ] || fail "единственный узел должен остаться active"
constraints=$(docker service inspect --format '{{json .Spec.TaskTemplate.Placement.Constraints}}' orders-api 2>/dev/null) || fail "service orders-api не найден"
jq -e 'index("node.role == manager") != null' <<<"$constraints" >/dev/null || fail "constraint node.role == manager не задан"
[ -f "$EVIDENCE" ] || fail "отсутствует $EVIDENCE"
jq -e \
  --arg id "$node_id" \
  --arg host "$(jq -r '.[0].Description.Hostname' <<<"$node_json")" \
  --arg availability "$(jq -r '.[0].Spec.Availability' <<<"$node_json")" \
  --arg manager "$(jq -r '.[0].ManagerStatus.Reachability // "none"' <<<"$node_json")" \
  --argjson constraints "$constraints" '
    .node_id == $id and
    .hostname == $host and
    .availability == $availability and
    .manager_status == $manager and
    .service_constraints == $constraints
  ' "$EVIDENCE" >/dev/null || fail "node-awareness.json не совпадает с фактическим состоянием"
[ "$(curl --fail --silent --max-time 5 http://127.0.0.1:18080/version | jq -r '.version')" = "v2" ] || fail "API потерял доступность"
echo "Node active; constraint и evidence подтверждены"
