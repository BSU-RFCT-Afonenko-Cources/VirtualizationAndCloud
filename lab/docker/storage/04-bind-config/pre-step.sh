#!/bin/bash
set -euo pipefail
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 /home/ubuntu/storage /home/ubuntu/storage/config /home/ubuntu/storage/assets
/usr/bin/docker image inspect python:3.12-alpine >/dev/null 2>&1 || /usr/bin/docker pull python:3.12-alpine
/usr/bin/docker volume inspect lab-data >/dev/null
/usr/bin/docker rm -f storage-api >/dev/null 2>&1 || /usr/bin/true
/usr/bin/rm -f /home/ubuntu/storage/config/api.json
/usr/bin/cat > /home/ubuntu/storage/assets/api.py <<'PYAPI'
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

CONFIG_PATH = "/app/config.json"


def payload():
    with open(CONFIG_PATH, encoding="utf-8") as config_file:
        config = json.load(config_file)
    with open(config["dataset"], encoding="utf-8") as dataset_file:
        records = json.load(dataset_file)
    return {"service": config["service_name"], "records": records}


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            try:
                payload()
                body, status = {"status": "ok"}, 200
            except Exception as error:
                body, status = {"status": "error", "detail": str(error)}, 503
        elif self.path == "/records":
            try:
                body, status = payload(), 200
            except Exception as error:
                body, status = {"error": str(error)}, 500
        else:
            body, status = {"error": "not found"}, 404
        encoded = json.dumps(body, ensure_ascii=False).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def log_message(self, format, *args):
        return


ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
PYAPI
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/storage/assets/api.py
/usr/bin/chmod 0444 /home/ubuntu/storage/assets/api.py
