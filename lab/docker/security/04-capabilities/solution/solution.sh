#!/bin/bash
set -euo pipefail
docker rm -f security-api >/dev/null 2>&1 || true
docker run -d --name security-api \
  -p 127.0.0.1:18080:8080 \
  --read-only \
  --tmpfs /home/ubuntu/docker-security/state:rw,noexec,nosuid,nodev,uid=10001,gid=10001,mode=0700 \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  security-api:lab >/dev/null
