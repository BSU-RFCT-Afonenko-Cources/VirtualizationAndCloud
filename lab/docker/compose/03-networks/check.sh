#!/usr/bin/env bash
set -euo pipefail
cd /home/ubuntu/compose-lab
docker compose config --quiet
docker compose up -d --build
python3 - <<'PY'
import json, subprocess
cfg=json.loads(subprocess.check_output(["docker","compose","config","--format","json"], text=True))
assert set(cfg["networks"]) == {"frontend", "backend"}
assert cfg["networks"]["backend"].get("internal") is True
expected={"web":{"frontend"},"api":{"frontend","backend"},"db":{"backend"}}
for service, nets in expected.items():
    assert set(cfg["services"][service]["networks"]) == nets
    cid=subprocess.check_output(["docker","compose","ps","-q",service], text=True).strip()
    actual=set(json.loads(subprocess.check_output(["docker","inspect",cid], text=True))[0]["NetworkSettings"]["Networks"])
    assert actual == {f"compose-lab_{n}" for n in nets}, (service, actual)
PY
echo "Сетевое разделение корректно"
