import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        status = 200 if self.path in ("/", "/health") else 404
        payload = {
            "service": "swarm-api",
            "hostname": os.uname().nodename,
            "path": self.path,
            "status": "ok" if status == 200 else "not-found",
        }
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
        print(f"swarm-api request path={self.path} status={status}", flush=True)

    def log_message(self, format, *args):
        return


ThreadingHTTPServer(("0.0.0.0", 8000), Handler).serve_forever()
