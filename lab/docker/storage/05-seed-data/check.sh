#!/bin/bash
set -euo pipefail
[ "$(/usr/bin/docker inspect --format '{{.State.Status}}' storage-init)" = exited ] || { /usr/bin/echo 'storage-init не завершён'; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.State.ExitCode}}' storage-init)" = 0 ] || { /usr/bin/echo 'storage-init завершился с ошибкой'; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{index .Config.Labels "course.role"}}' storage-init)" = init ] || { /usr/bin/echo 'Нет label course.role=init'; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Name}}{{end}}{{end}}' storage-init)" = lab-data ] || { /usr/bin/echo 'Init-контейнер не использовал lab-data'; exit 1; }
/usr/bin/curl --fail --silent http://127.0.0.1:8080/records | /usr/bin/python3 -c 'import json,sys; p=json.load(sys.stdin); expected=[{"id":"seed-1","value":"alpha"},{"id":"seed-2","value":"beta"},{"id":"seed-3","value":"gamma"}]; assert p["records"] == expected'
