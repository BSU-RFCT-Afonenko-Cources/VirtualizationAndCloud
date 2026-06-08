#!/usr/bin/env bash
set -euo pipefail
cd /home/ubuntu/compose-lab
docker compose config --quiet
mapfile -t services < <(docker compose config --services | sort)
test "${services[*]}" = "api db web" || { echo "Ожидаются services: api db web"; exit 1; }
test "$(docker compose config --format json | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["name"])')" = compose-lab
python3 - <<'PY'
import json, subprocess
c=json.loads(subprocess.check_output(["docker","compose","config","--format","json"], text=True))
assert c["services"]["api"].get("build")
assert c["services"]["db"]["image"].startswith("redis:")
assert c["services"]["web"]["image"].startswith("nginx:")
ports=c["services"]["web"].get("ports", [])
assert any(str(p.get("published")) == "8080" and str(p.get("target")) == "80" for p in ports)
assert not c["services"]["api"].get("ports") and not c["services"]["db"].get("ports")
PY
docker compose up -d --build
for service in api db web; do test -n "$(docker compose ps -q "$service")" || exit 1; done
echo "Три сервиса описаны и запущены"
