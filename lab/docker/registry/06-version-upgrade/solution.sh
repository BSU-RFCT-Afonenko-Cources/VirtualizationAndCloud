#!/bin/bash
set -euo pipefail

/usr/bin/docker build --label course.lab=registry --label course.version=v2 --tag localhost:5000/course/api:v2 /home/ubuntu/registry/app-v2
/usr/bin/docker push localhost:5000/course/api:v2
/usr/bin/docker rm --force registry-api-v2 >/dev/null 2>&1 || true
/usr/bin/docker run --detach --name registry-api-v2 --publish 18081:8080 localhost:5000/course/api:v2
for attempt in $(/usr/bin/seq 1 30); do
  [ "$(/usr/bin/docker inspect --format '{{.State.Health.Status}}' registry-api-v2 2>/dev/null || true)" = "healthy" ] && exit 0
  /usr/bin/sleep 1
done
echo "API v2 не перешёл в healthy-состояние"
exit 1
