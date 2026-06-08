#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation
ASSETS=/opt/capstone-process-hibernation/assets
install -m 0644 "${ASSETS}/Dockerfile.hib" "${LAB}/src/Dockerfile"
install -m 0755 "${ASSETS}/hib_worker.py" "${LAB}/src/hib_worker.py"
docker rm -f hib-worker >/dev/null 2>&1 || true
docker build -t hib-worker:lab -f "${LAB}/src/Dockerfile" "${LAB}/src"
docker run -d --name hib-worker --hostname hib-status -p 127.0.0.1:18080:8080 -v "${LAB}/data:/data" hib-worker:lab >/dev/null
for _ in $(seq 1 30); do curl -fsS http://127.0.0.1:18080/hib-status > "${LAB}/evidence/progress-before.json" && break; sleep 1; done
sleep 2
curl -fsS http://127.0.0.1:18080/hib-status > "${LAB}/evidence/progress-after.json"
chown -R ubuntu:ubuntu "${LAB}"
