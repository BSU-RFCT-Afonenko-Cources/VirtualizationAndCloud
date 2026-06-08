#!/bin/bash
set -euo pipefail

/usr/bin/install -d -o ubuntu -g ubuntu /home/ubuntu/registry/app-v1 /home/ubuntu/registry/app-v2

/usr/bin/tee /home/ubuntu/registry/app-v1/app.py >/dev/null <<'PY'
import json
from http.server import BaseHTTPRequestHandler, HTTPServer

VERSION = "v1"

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path not in ("/", "/health", "/version"):
            self.send_response(404)
            self.end_headers()
            return
        payload = {"service": "course-registry-api", "version": VERSION}
        if self.path == "/health":
            payload["status"] = "ok"
        body = json.dumps(payload).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        return

HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
PY
/usr/bin/sed 's/VERSION = "v1"/VERSION = "v2"/' /home/ubuntu/registry/app-v1/app.py > /home/ubuntu/registry/app-v2/app.py

for version in v1 v2; do
  /usr/bin/tee "/home/ubuntu/registry/app-${version}/Dockerfile" >/dev/null <<'DOCKERFILE'
FROM python:3.13-alpine
WORKDIR /app
COPY app.py /app/app.py
EXPOSE 8080
HEALTHCHECK --interval=2s --timeout=1s --retries=10 CMD wget -q -O /dev/null http://127.0.0.1:8080/health || exit 1
CMD ["python", "/app/app.py"]
DOCKERFILE
done
/usr/bin/chown -R ubuntu:ubuntu /home/ubuntu/registry

if ! /usr/bin/docker image inspect course-registry-api:build-v1 >/dev/null 2>&1; then
  /usr/bin/docker build --label course.lab=registry --label course.version=v1 --tag course-registry-api:build-v1 /home/ubuntu/registry/app-v1
fi
