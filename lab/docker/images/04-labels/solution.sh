#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path
path = Path('/home/ubuntu/image-lab/Dockerfile')
text = path.read_text()
marker = 'WORKDIR /app\n'
labels = ('LABEL maintainer="student@course.local" \\\n'
          '      course="virtualization-and-cloud" \\\n'
          '      component="image-lab-api"\n')
if 'LABEL maintainer=' not in text:
    text = text.replace(marker, marker + labels)
path.write_text(text)
PY
chown ubuntu:ubuntu /home/ubuntu/image-lab/Dockerfile
docker build --tag image-lab:v1 --tag image-lab:latest /home/ubuntu/image-lab
docker container rm --force image-lab-api >/dev/null 2>&1 || true
docker run --detach --name image-lab-api --publish 18080:8080 image-lab:latest >/dev/null
