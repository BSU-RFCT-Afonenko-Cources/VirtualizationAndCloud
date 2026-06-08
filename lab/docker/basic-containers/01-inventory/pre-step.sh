#!/bin/bash
set -euo pipefail
/usr/bin/install -d -m 0755 -o ubuntu -g ubuntu /home/ubuntu/basic-containers /home/ubuntu/basic-containers/evidence
/usr/bin/install -d -m 0755 /var/lib/basic-containers/image
/usr/bin/tee /var/lib/basic-containers/image/app.py >/dev/null <<'PYAPP'
import json
import logging
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s", force=True)

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        target = urlsplit(self.path)
        payload = {
            "service": "lab-http",
            "endpoint": target.path,
            "query": target.query,
            "hostname": os.uname().nodename,
        }
        body = json.dumps(payload, sort_keys=True).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
        logging.info("http_request method=GET path=%s", self.path)

    def log_message(self, format, *args):
        return

ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
PYAPP
/usr/bin/tee /var/lib/basic-containers/image/Dockerfile >/dev/null <<'DOCKERFILE'
FROM python:3.12-alpine
WORKDIR /opt/lab
COPY app.py /opt/lab/app.py
EXPOSE 8080
HEALTHCHECK --interval=2s --timeout=2s --retries=10 CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=1)"
CMD ["python", "-u", "/opt/lab/app.py"]
DOCKERFILE
/usr/bin/docker info >/dev/null
/usr/bin/docker build --label com.course.lab=basic-containers --tag lab-http-image:1.0 /var/lib/basic-containers/image
/usr/bin/docker pull curlimages/curl:8.12.1
/usr/bin/chown -R ubuntu:ubuntu /home/ubuntu/basic-containers
