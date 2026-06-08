#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path
path = Path('/home/ubuntu/image-lab/Dockerfile')
text = path.read_text()
if 'useradd' not in text:
    text = text.replace('WORKDIR /app\n', 'RUN useradd --create-home --uid 10001 app\nWORKDIR /app\n')
if '\nUSER app\n' not in text:
    text = text.replace('\nCMD [', '\nUSER app\nCMD [')
path.write_text(text)
PY
chown ubuntu:ubuntu /home/ubuntu/image-lab/Dockerfile
docker build --tag image-lab:v2 --tag image-lab:latest /home/ubuntu/image-lab
docker container rm --force image-lab-api >/dev/null 2>&1 || true
docker run --detach --name image-lab-api --publish 18080:8080 image-lab:latest >/dev/null
