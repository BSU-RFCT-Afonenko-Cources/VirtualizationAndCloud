#!/bin/bash
set -euo pipefail

WORKDIR=/home/ubuntu/docker-security
install -d -m 0755 -o ubuntu -g ubuntu "$WORKDIR"
install -d -m 0755 -o ubuntu -g ubuntu "$WORKDIR/runtime"
install -d -m 0700 -o ubuntu -g ubuntu "$WORKDIR/runtime/secret"
install -m 0644 -o ubuntu -g ubuntu /workspace/VirtualizationAndCloud/lab/docker/security/prepare/assets/app.py "$WORKDIR/app.py"
python3 - <<'PYSECRET' > "$WORKDIR/runtime/secret/db_password"
import secrets
print("lab-db-password-" + secrets.token_hex(12))
PYSECRET
chown 10001:10001 "$WORKDIR/runtime/secret/db_password"
chmod 0400 "$WORKDIR/runtime/secret/db_password"
rm -f "$WORKDIR/threat-model.json" "$WORKDIR/app.env" "$WORKDIR/image-evidence.json"
docker rm -f security-api >/dev/null 2>&1 || true
docker image rm security-api:lab >/dev/null 2>&1 || true
