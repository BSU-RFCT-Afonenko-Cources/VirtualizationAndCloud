#!/bin/bash
set -euo pipefail
/usr/bin/sha256sum --check /home/ubuntu/storage/backups/lab-data.tar.gz.sha256
/usr/bin/docker rm -f storage-restore storage-api-restore >/dev/null 2>&1 || /usr/bin/true
/usr/bin/docker volume rm lab-data-restore >/dev/null 2>&1 || /usr/bin/true
/usr/bin/docker volume create --label course.lab=storage lab-data-restore >/dev/null
/usr/bin/docker run --name storage-restore --label course.role=restore --mount type=volume,src=lab-data-restore,dst=/data --mount type=bind,src=/home/ubuntu/storage/backups,dst=/backup,readonly alpine:3.20 /bin/sh -c '/bin/tar -xzf /backup/lab-data.tar.gz -C /data'
/usr/bin/docker run -d --name storage-api-restore --label course.lab=storage --publish 127.0.0.1:8081:8080 --mount type=volume,src=lab-data-restore,dst=/data,readonly --mount type=bind,src=/home/ubuntu/storage/config/api.json,dst=/app/config.json,readonly --mount type=bind,src=/home/ubuntu/storage/assets/api.py,dst=/app/api.py,readonly --health-cmd '/usr/local/bin/python -c "import urllib.request; urllib.request.urlopen(\"http://127.0.0.1:8080/health\", timeout=2).read()"' --health-interval 2s --health-timeout 3s --health-retries 15 python:3.12-alpine /usr/local/bin/python /app/api.py >/dev/null
for attempt in $(/usr/bin/seq 1 30); do
  [ "$(/usr/bin/docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{end}}' storage-api-restore)" = healthy ] && exit 0
  /usr/bin/sleep 1
done
/usr/bin/docker logs storage-api-restore
exit 1
