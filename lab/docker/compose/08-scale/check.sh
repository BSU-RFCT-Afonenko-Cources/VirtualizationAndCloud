#!/usr/bin/env bash
set -euo pipefail
cd /home/ubuntu/compose-lab
mapfile -t apis < <(docker compose ps -q api)
test "${#apis[@]}" -eq 3 || { echo "Ожидается 3 контейнера api, найдено ${#apis[@]}"; exit 1; }
test "$(docker compose ps -q db | wc -l)" -eq 1
test "$(docker compose ps -q web | wc -l)" -eq 1
for cid in "${apis[@]}"; do test "$(docker inspect "$cid" --format '{{.State.Health.Status}}')" = healthy; done
declare -A seen=()
for _ in $(seq 1 30); do body=$(curl -fsS http://127.0.0.1:8080/data); instance=$(python3 -c 'import json,sys; print(json.load(sys.stdin)["instance"])' <<<"$body"); seen["$instance"]=1; done
test "${#seen[@]}" -ge 2 || { echo "Proxy не распределил запросы между экземплярами API"; exit 1; }
echo "API масштабирован, замечено экземпляров: ${#seen[@]}"
