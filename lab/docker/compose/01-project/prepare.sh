#!/usr/bin/env bash
set -euo pipefail
install -d -m 0755 /home/ubuntu/compose-lab/starter/api /home/ubuntu/compose-lab/starter/web
cat > /home/ubuntu/compose-lab/starter/api/app.py <<'PYAPP'
import json
import os
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

DB_HOST = os.environ.get("DB_HOST", "db")
DB_PORT = int(os.environ.get("DB_PORT", "6379"))
VERSION = Path("/app/version.txt").read_text(encoding="utf-8").strip()

def redis(*parts):
    payload = f"*{len(parts)}\r\n" + "".join(f"${len(str(p))}\r\n{p}\r\n" for p in parts)
    with socket.create_connection((DB_HOST, DB_PORT), timeout=2) as sock:
        sock.sendall(payload.encode())
        line = sock.makefile("rb").readline().decode().strip()
    if line.startswith(":"):
        return int(line[1:])
    if line.startswith("+"):
        return line[1:]
    raise RuntimeError(line)

class Handler(BaseHTTPRequestHandler):
    def reply(self, status, data):
        body = json.dumps(data).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        try:
            if self.path == "/health":
                self.reply(200, {"status": "ok", "db": redis("PING")})
            elif self.path == "/version":
                self.reply(200, {"version": VERSION})
            elif self.path == "/data":
                self.reply(200, {"visits": redis("INCR", "lab:visits"), "instance": socket.gethostname(), "version": VERSION})
            else:
                self.reply(404, {"error": "not found"})
        except Exception as error:
            self.reply(503, {"error": str(error)})

    def log_message(self, format, *args):
        return

ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
PYAPP
cat > /home/ubuntu/compose-lab/starter/api/Dockerfile <<'DOCKERFILE'
FROM python:3.13-alpine
WORKDIR /app
COPY app.py version.txt ./
EXPOSE 8080
CMD ["python", "app.py"]
DOCKERFILE
printf '1.0\n' > /home/ubuntu/compose-lab/starter/api/version.txt
cat > /home/ubuntu/compose-lab/starter/web/default.conf.template <<'NGINX'
server {
    listen 80;
    resolver 127.0.0.11 valid=2s ipv6=off;
    location / {
        set $api http://api:8080;
        proxy_pass $api;
        proxy_set_header Host $host;
    }
}
NGINX
chmod -R a+rX /home/ubuntu/compose-lab/starter
rm -rf /home/ubuntu/compose-lab
