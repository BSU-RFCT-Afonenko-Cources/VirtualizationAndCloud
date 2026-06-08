#!/usr/bin/env bash
set -euo pipefail

cat > /home/ubuntu/image-lab/Dockerfile <<'DOCKERFILE'
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py VERSION ./
EXPOSE 8080
CMD ["python", "app.py"]
DOCKERFILE
chown ubuntu:ubuntu /home/ubuntu/image-lab/Dockerfile
docker build --tag image-lab:build /home/ubuntu/image-lab
docker container rm --force image-lab-api >/dev/null 2>&1 || true
docker run --detach --name image-lab-api --publish 18080:8080 image-lab:build >/dev/null
