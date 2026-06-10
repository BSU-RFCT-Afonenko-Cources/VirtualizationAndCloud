import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ENDPOINT = os.environ.get("APP_ENDPOINT", "/api/status")
VERSION = os.environ.get("APP_VERSION", "development")
SECRET_FILE = Path(os.environ.get("DB_SECRET_FILE", "/run/secrets/db_password"))
STATE_FILE = Path("/home/ubuntu/docker-security/state/request-count.txt")


def load_secret():
    try:
        value = SECRET_FILE.read_text(encoding="utf-8").strip()
    except OSError:
        return None
    return value or None


class Handler(BaseHTTPRequestHandler):
    def send_json(self, status, payload):
        body = json.dumps(payload, sort_keys=True).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/health":
            self.send_json(200, {"status": "ok"})
            return
        if self.path != ENDPOINT:
            self.send_json(404, {"error": "not found"})
            return
        try:
            count = int(STATE_FILE.read_text(encoding="utf-8")) + 1
        except (OSError, ValueError):
            count = 1
        STATE_FILE.write_text(str(count), encoding="utf-8")
        self.send_json(200, {
            "service": "hardened-api",
            "version": VERSION,
            "request_count": count,
            "secret_loaded": load_secret() is not None,
        })

    def log_message(self, format, *args):
        print(f"request path={self.path} status={args[1]}", flush=True)


ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
