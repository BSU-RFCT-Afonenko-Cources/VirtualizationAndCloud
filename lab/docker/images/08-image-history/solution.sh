#!/usr/bin/env bash
set -euo pipefail

install -d -o ubuntu -g ubuntu /home/ubuntu/image-lab/evidence
docker image history --no-trunc --format '{{json .}}' image-lab:v2 | python3 -c 'import json,sys; json.dump([json.loads(line) for line in sys.stdin if line.strip()], sys.stdout, ensure_ascii=False, indent=2); print()' > /home/ubuntu/image-lab/evidence/image-history.json
chown ubuntu:ubuntu /home/ubuntu/image-lab/evidence/image-history.json
