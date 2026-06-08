#!/bin/bash
set -euo pipefail
SECRET=/home/ubuntu/docker-security/runtime/secret/db_password
docker rm -f security-api >/dev/null 2>&1 || true
docker run -d --name security-api \
  -p 127.0.0.1:18080:8080 \
  --read-only \
  --tmpfs /var/lib/hardened-api:rw,noexec,nosuid,nodev,uid=10001,gid=10001,mode=0700 \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --mount type=bind,src="$SECRET",dst=/run/secrets/db_password,readonly \
  -e DB_SECRET_FILE=/run/secrets/db_password \
  security-api:lab >/dev/null
