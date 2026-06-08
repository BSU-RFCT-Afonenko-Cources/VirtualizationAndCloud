#!/bin/bash
set -euo pipefail
! /usr/bin/docker inspect storage-db >/dev/null 2>&1 || { /usr/bin/echo 'Старый storage-db не удалён'; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.State.Running}}' storage-db-v2)" = true ] || { /usr/bin/echo 'storage-db-v2 не запущен'; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Name}}{{end}}{{end}}' storage-db-v2)" = lab-data ] || { /usr/bin/echo 'storage-db-v2 не использует lab-data в /data'; exit 1; }
/usr/bin/docker exec storage-db-v2 /bin/cat /data/records.json | /usr/bin/python3 -c 'import json,sys; data=json.load(sys.stdin); assert {"id":"persistent-1","value":"survived-recreate"} in data'
