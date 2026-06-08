#!/usr/bin/python3
import os
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

TARGET_HOST = os.environ.get("TARGET_HOST", "net-api")
TARGET_PORT = os.environ.get("TARGET_PORT", "8080")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        target = f"http://{TARGET_HOST}:{TARGET_PORT}{self.path}"
        try:
            with urllib.request.urlopen(target, timeout=3) as response:
                body = response.read()
                self.send_response(response.status)
                self.send_header("Content-Type", response.headers.get_content_type())
                self.send_header("Content-Length", str(len(body)))
                self.send_header("X-Lab-Proxy", "net-proxy")
                self.end_headers()
                self.wfile.write(body)
        except (urllib.error.URLError, TimeoutError) as error:
            body = str(error).encode()
            self.send_response(502)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

    def log_message(self, format, *args):
        return


ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
