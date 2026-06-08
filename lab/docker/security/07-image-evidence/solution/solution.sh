#!/bin/bash
set -euo pipefail
WORKDIR=/home/ubuntu/docker-security
BASE=python:3.13-alpine
DIGEST=$(docker image inspect -f '{{index .RepoDigests 0}}' "$BASE" 2>/dev/null | sed 's/.*@//' || true)
if [ -z "$DIGEST" ] || [ "$DIGEST" = '<no value>' ]; then
  DIGEST=$(docker image inspect -f '{{.Id}}' "$BASE")
fi
python3 - "$DIGEST" > "$WORKDIR/image-evidence.json" <<'PY'
import json, sys
print(json.dumps({
    'base_image': 'python:3.13-alpine',
    'base_digest': sys.argv[1],
    'application_image': 'security-api:lab',
    'application_version': '1.0.0',
    'scan_status': 'local-metadata-checked'
}, indent=2))
PY
chown ubuntu:ubuntu "$WORKDIR/image-evidence.json"
