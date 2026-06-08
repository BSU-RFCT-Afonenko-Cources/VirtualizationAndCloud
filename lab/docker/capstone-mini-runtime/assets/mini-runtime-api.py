#!/usr/bin/python3
import json
import os
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


def read_text(path, default="unavailable"):
    try:
        with open(path, encoding="utf-8") as stream:
            return stream.read().strip()
    except OSError:
        return default


def cgroup_path():
    for line in read_text("/proc/self/cgroup", "").splitlines():
        fields = line.split(":", 2)
        if len(fields) == 3 and fields[0] == "0":
            return fields[2]
    return "unavailable"


def payload():
    return {
        "service": "mini-runtime-api",
        "hostname": socket.gethostname(),
        "pid": os.getpid(),
        "pid_view": read_text("/proc/self/status"),
        "cgroup": cgroup_path(),
        "limits": {
            "memory_max": read_text("/sys/fs/cgroup/mini-runtime/memory.max"),
            "pids_max": read_text("/sys/fs/cgroup/mini-runtime/pids.max"),
            "cpu_max": read_text("/sys/fs/cgroup/mini-runtime/cpu.max"),
        },
        "rootfs_marker": read_text("/.mini-runtime-rootfs"),
        "runtime_state_writable": os.access("/run/mini-runtime", os.W_OK),
    }


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/status":
            self.send_error(404)
            return
        body = json.dumps(payload(), sort_keys=True).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        with open("/run/mini-runtime/api.log", "a", encoding="utf-8") as stream:
            stream.write((fmt % args) + "\n")


ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
