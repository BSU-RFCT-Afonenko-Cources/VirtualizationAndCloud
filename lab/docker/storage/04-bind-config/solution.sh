#!/bin/bash
set -euo pipefail
/usr/bin/printf '%s\n' '{"service_name":"storage-api","dataset":"/data/records.json"}' > /home/ubuntu/storage/config/api.json
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/storage/config/api.json
/usr/bin/docker rm -f storage-api >/dev/null 2>&1 || /usr/bin/true
/usr/bin/docker run -d --name storage-api --label course.lab=storage --publish 127.0.0.1:8080:8080 --mount type=volume,src=lab-data,dst=/data,readonly --mount type=bind,src=/home/ubuntu/storage/config/api.json,dst=/app/config.json,readonly --mount type=bind,src=/home/ubuntu/storage/assets/api.py,dst=/app/api.py,readonly --health-cmd '/usr/local/bin/python -c "import urllib.request; urllib.request.urlopen(\"http://127.0.0.1:8080/health\", timeout=2).read()"' --health-interval 2s --health-timeout 3s --health-retries 15 python:3.12-alpine /usr/local/bin/python /app/api.py >/dev/null
for attempt in $(/usr/bin/seq 1 30); do
  [ "$(/usr/bin/docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{end}}' storage-api)" = healthy ] && exit 0
  /usr/bin/sleep 1
done
/usr/bin/docker logs storage-api
exit 1
