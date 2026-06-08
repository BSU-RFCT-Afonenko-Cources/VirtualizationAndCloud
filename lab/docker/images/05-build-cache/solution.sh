#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' '2.0.0' > /home/ubuntu/image-lab/VERSION
python3 - <<'PY'
from pathlib import Path
path = Path('/home/ubuntu/image-lab/Dockerfile')
text = path.read_text()
needle = '      component="image-lab-api"\n'
if 'org.opencontainers.image.version=' not in text:
    text = text.replace(needle, '      component="image-lab-api" \\\n      org.opencontainers.image.version="2.0.0"\n')
else:
    import re
    text = re.sub(r'org\.opencontainers\.image\.version="[^"]+"', 'org.opencontainers.image.version="2.0.0"', text)
path.write_text(text)
PY
chown ubuntu:ubuntu /home/ubuntu/image-lab/VERSION /home/ubuntu/image-lab/Dockerfile
docker build --tag image-lab:v2 --tag image-lab:latest /home/ubuntu/image-lab
docker container rm --force image-lab-api >/dev/null 2>&1 || true
docker run --detach --name image-lab-api --publish 18080:8080 image-lab:latest >/dev/null
