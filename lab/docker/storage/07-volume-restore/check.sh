#!/bin/bash
set -euo pipefail
/usr/bin/sha256sum --check /home/ubuntu/storage/backups/lab-data.tar.gz.sha256
[ "$(/usr/bin/docker volume inspect --format '{{index .Labels "course.lab"}}' lab-data-restore)" = storage ] || { /usr/bin/echo 'Нет volume lab-data-restore с нужным label'; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.State.ExitCode}}' storage-restore)" = 0 ] || { /usr/bin/echo 'storage-restore завершился с ошибкой'; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{index .Config.Labels "course.role"}}' storage-restore)" = restore ] || { /usr/bin/echo 'Нет label course.role=restore'; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.State.Health.Status}}' storage-api-restore)" = healthy ] || { /usr/bin/echo 'storage-api-restore не healthy'; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Name}}:{{.RW}}{{end}}{{end}}' storage-api-restore)" = lab-data-restore:false ] || { /usr/bin/echo 'Restore API не использует lab-data-restore read-only'; exit 1; }
/usr/bin/python3 - <<'PYDOCKER'
import json, subprocess
info = json.loads(subprocess.check_output(['/usr/bin/docker', 'inspect', 'storage-api-restore']))[0]
assert info['HostConfig']['PortBindings']['8080/tcp'] == [{'HostIp': '127.0.0.1', 'HostPort': '8081'}]
PYDOCKER
/usr/bin/curl --fail --silent http://127.0.0.1:8081/records | /usr/bin/python3 -c 'import json,sys; p=json.load(sys.stdin); assert [r["id"] for r in p["records"]] == ["seed-1","seed-2","seed-3"]'
