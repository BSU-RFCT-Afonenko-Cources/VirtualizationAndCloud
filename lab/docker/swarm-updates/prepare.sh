#!/usr/bin/env bash
set -euo pipefail

LAB_DIR=/home/ubuntu/swarm-updates
BUILD_DIR=/home/ubuntu/swarm-updates/build
EVIDENCE_DIR=/home/ubuntu/swarm-updates/evidence

install -d -o ubuntu -g ubuntu "$BUILD_DIR" "$EVIDENCE_DIR"

cat > "$BUILD_DIR/app.py" <<'PY'
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

VERSION = os.environ.get("APP_VERSION", "unknown")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/version":
            self.respond(200, {"service": "orders-api", "version": VERSION})
        elif self.path == "/health":
            status = 503 if VERSION == "bad" else 200
            self.respond(status, {"status": "unhealthy" if status == 503 else "ok", "version": VERSION})
        elif self.path == "/orders":
            self.respond(200, {"orders": [{"id": 101, "status": "accepted"}], "version": VERSION})
        else:
            self.respond(404, {"error": "not found"})

    def respond(self, status, payload):
        body = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        return


ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
PY

cat > "$BUILD_DIR/Dockerfile" <<'DOCKERFILE'
FROM python:3.12-alpine
ARG APP_VERSION
ENV APP_VERSION=${APP_VERSION}
WORKDIR /app
COPY app.py /app/app.py
EXPOSE 8080
CMD ["python", "/app/app.py"]
DOCKERFILE

chown ubuntu:ubuntu "$BUILD_DIR/app.py" "$BUILD_DIR/Dockerfile"

if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -qx active; then
  docker swarm init --advertise-addr 127.0.0.1 >/dev/null
fi

docker service rm orders-api >/dev/null 2>&1 || true
for version in v1 v2 bad; do
  docker build --quiet --build-arg "APP_VERSION=$version" --tag "orders-api:$version" "$BUILD_DIR" >/dev/null
done

chown -R ubuntu:ubuntu "$LAB_DIR"
