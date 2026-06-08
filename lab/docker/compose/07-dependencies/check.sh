#!/usr/bin/env bash
set -euo pipefail
cd /home/ubuntu/compose-lab
python3 - <<'PY'
import json, subprocess
cfg=json.loads(subprocess.check_output(["docker","compose","config","--format","json"], text=True))
assert cfg["services"]["api"]["depends_on"]["db"]["condition"] == "service_healthy"
assert cfg["services"]["web"]["depends_on"]["api"]["condition"] == "service_healthy"
PY
docker compose down --remove-orphans
docker compose up -d --build
for _ in $(seq 1 60); do curl -fsS http://127.0.0.1:8080/health >/dev/null 2>&1 && break; sleep 1; done
curl -fsS http://127.0.0.1:8080/health | python3 -c 'import json,sys; assert json.load(sys.stdin)["status"] == "ok"'
for service in db api web; do cid=$(docker compose ps -q "$service"); test "$(docker inspect "$cid" --format '{{.State.Health.Status}}')" = healthy; done
echo "Холодный запуск с health-зависимостями успешен"
