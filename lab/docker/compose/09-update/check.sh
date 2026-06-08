#!/usr/bin/env bash
set -euo pipefail
cd /home/ubuntu/compose-lab
test "$(tr -d '[:space:]' < /home/ubuntu/compose-lab/api/version.txt)" = 2.0 || { echo "Файл версии не обновлён до 2.0"; exit 1; }
before=$(curl -fsS http://127.0.0.1:8080/data | python3 -c 'import json,sys; print(json.load(sys.stdin)["visits"])')
version=$(curl -fsS http://127.0.0.1:8080/version | python3 -c 'import json,sys; print(json.load(sys.stdin)["version"])')
test "$version" = 2.0 || { echo "Запущенный API сообщает версию $version"; exit 1; }
after=$(curl -fsS http://127.0.0.1:8080/data | python3 -c 'import json,sys; print(json.load(sys.stdin)["visits"])')
test "$after" -gt "$before" || { echo "Счётчик Redis не сохранился"; exit 1; }
mapfile -t apis < <(docker compose ps -q api)
test "${#apis[@]}" -eq 3 || { echo "После rollout ожидаются 3 API"; exit 1; }
for cid in "${apis[@]}"; do test "$(docker exec "$cid" cat /app/version.txt | tr -d '[:space:]')" = 2.0; done
echo "API обновлён до 2.0, данные БД сохранены"
