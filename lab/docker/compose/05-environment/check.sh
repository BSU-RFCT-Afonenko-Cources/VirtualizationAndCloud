#!/usr/bin/env bash
set -euo pipefail
cd /home/ubuntu/compose-lab
docker compose up -d --build
python3 - <<'PY'
import json, subprocess
cfg=json.loads(subprocess.check_output(["docker","compose","config","--format","json"], text=True))
env=cfg["services"]["api"].get("environment", {})
assert env.get("DB_HOST") == "db"
assert str(env.get("DB_PORT")) == "6379"
assert not any(k in env for k in ("PASSWORD","SECRET","TOKEN"))
PY
body=
for _ in $(seq 1 30); do body=$(curl -fsS http://127.0.0.1:8080/data 2>/dev/null) && break; sleep 1; done
test -n "$body"
python3 -c 'import json,sys; d=json.loads(sys.argv[1]); assert isinstance(d["visits"], int) and d["instance"]' "$body"
echo "API получает конфигурацию базы и отвечает через web"
