#!/bin/bash
set -euo pipefail
WORKDIR=/home/ubuntu/docker-security
cat > "$WORKDIR/Dockerfile" <<'DOCKERFILE'
FROM python:3.13-alpine
LABEL org.opencontainers.image.title="hardened-api" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.base.name="python:3.13-alpine"
RUN addgroup -g 10001 app && adduser -D -H -u 10001 -G app app \
    && mkdir -p /home/ubuntu/docker-security/state && chown app:app /home/ubuntu/docker-security/state
WORKDIR /home/ubuntu/docker-security/app
COPY --chown=10001:10001 app.py /home/ubuntu/docker-security/app/app.py
USER 10001:10001
EXPOSE 8080
HEALTHCHECK --interval=5s --timeout=2s --start-period=2s --retries=5 \
  CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=1)"]
CMD ["python", "/home/ubuntu/docker-security/app/app.py"]
DOCKERFILE
chown ubuntu:ubuntu "$WORKDIR/Dockerfile"
docker build -t security-api:lab "$WORKDIR"
docker rm -f security-api >/dev/null 2>&1 || true
docker run -d --name security-api -p 127.0.0.1:18080:8080 security-api:lab >/dev/null
