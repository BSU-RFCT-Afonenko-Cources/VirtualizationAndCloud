#!/bin/bash
set -euo pipefail
[ "$(/usr/bin/docker inspect --format '{{.State.Status}}' storage-backup)" = exited ] || { /usr/bin/echo 'storage-backup не завершён'; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.State.ExitCode}}' storage-backup)" = 0 ] || { /usr/bin/echo 'storage-backup завершился с ошибкой'; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{index .Config.Labels "course.role"}}' storage-backup)" = backup ] || { /usr/bin/echo 'Нет label course.role=backup'; exit 1; }
/usr/bin/test -s /home/ubuntu/storage/backups/lab-data.tar.gz
/usr/bin/test -s /home/ubuntu/storage/backups/lab-data.tar.gz.sha256
/usr/bin/sha256sum --check /home/ubuntu/storage/backups/lab-data.tar.gz.sha256
/usr/bin/tar -tzf /home/ubuntu/storage/backups/lab-data.tar.gz | /usr/bin/grep -Eq '(^|/)records.json$' || { /usr/bin/echo 'В архиве нет records.json'; exit 1; }
/usr/bin/tar -xOzf /home/ubuntu/storage/backups/lab-data.tar.gz records.json | /usr/bin/python3 -c 'import json,sys; data=json.load(sys.stdin); assert len(data) == 3 and {r["id"] for r in data} == {"seed-1","seed-2","seed-3"}'
