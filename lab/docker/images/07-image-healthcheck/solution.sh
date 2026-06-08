#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path
path = Path('/home/ubuntu/image-lab/Dockerfile')
text = path.read_text()
health = 'HEALTHCHECK --interval=5s --timeout=2s --start-period=2s --retries=3 CMD ["python", "-c", "import urllib.request; urllib.request.urlopen(\'http://127.0.0.1:8080/health\', timeout=1).read()"]\n'
if 'HEALTHCHECK ' not in text:
    text = text.replace('\nUSER app\n', '\n' + health + 'USER app\n')
path.write_text(text)
PY
chown ubuntu:ubuntu /home/ubuntu/image-lab/Dockerfile
docker build --tag image-lab:v2 --tag image-lab:latest /home/ubuntu/image-lab
docker container rm --force image-lab-api >/dev/null 2>&1 || true
docker run --detach --name image-lab-api --publish 18080:8080 image-lab:latest >/dev/null
