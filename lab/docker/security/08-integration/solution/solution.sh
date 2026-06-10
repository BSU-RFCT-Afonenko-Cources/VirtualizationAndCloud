#!/bin/bash
set -euo pipefail
WORKDIR=/home/ubuntu/docker-security
SECRET="$WORKDIR/runtime/secret/db_password"
docker rm -f security-api >/dev/null 2>&1 || true
docker run -d --name security-api \
  --restart unless-stopped \
  -p 127.0.0.1:18080:8080 \
  --read-only \
  --tmpfs /home/ubuntu/docker-security/state:rw,noexec,nosuid,nodev,uid=10001,gid=10001,mode=0700 \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --mount type=bind,src="$SECRET",dst=/run/secrets/db_password,readonly \
  --env-file "$WORKDIR/app.env" \
  security-api:lab >/dev/null
for _ in $(seq 1 15); do
  [ "$(docker inspect -f '{{.State.Health.Status}}' security-api)" = healthy ] && exit 0
  sleep 1
done
echo "Контейнер не перешёл в healthy" >&2
exit 1
