#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
[ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = active ] || fail "Swarm не активен"
node_id=$(docker info --format '{{.Swarm.NodeID}}')
[ "$(docker node inspect --format '{{.Spec.Role}}' "$node_id")" = manager ] || fail "Узел не manager"
[ "$(docker node inspect --format '{{.Spec.Availability}}' "$node_id")" = active ] || fail "Узел недоступен scheduler"
file=/home/ubuntu/capstone-swarm/evidence/swarm-inventory.json
jq -e --arg id "$node_id" '.swarm=="active" and .node_id==$id and .role=="manager" and .availability=="active" and (.hostname|length>0) and (.manager_state=="reachable" or .manager_state=="leader")' "$file" >/dev/null || fail "Некорректный evidence swarm-inventory.json"
echo "OK: Swarm inventory подтверждён"
