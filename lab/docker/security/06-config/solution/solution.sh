#!/bin/bash
set -euo pipefail
WORKDIR=/home/ubuntu/docker-security
SECRET="$WORKDIR/runtime/secret/db_password"
cat > "$WORKDIR/app.env" <<'ENV'
APP_ENDPOINT=/api/security
APP_VERSION=1.0.0
DB_SECRET_FILE=/run/secrets/db_password
ENV
chown ubuntu:ubuntu "$WORKDIR/app.env"
chmod 0644 "$WORKDIR/app.env"
docker rm -f security-api >/dev/null 2>&1 || true
docker run -d --name security-api \
  -p 127.0.0.1:18080:8080 \
  --read-only \
  --tmpfs /var/lib/hardened-api:rw,noexec,nosuid,nodev,uid=10001,gid=10001,mode=0700 \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --mount type=bind,src="$SECRET",dst=/run/secrets/db_password,readonly \
  --env-file "$WORKDIR/app.env" \
  security-api:lab >/dev/null
