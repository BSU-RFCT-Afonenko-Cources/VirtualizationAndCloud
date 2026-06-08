#!/usr/bin/env python3
import hashlib
import http.server
import json
import os
import pathlib
import signal
import socketserver
import sys
import threading
import time
import uuid

DATA_DIR = pathlib.Path(os.environ.get("HIB_DATA_DIR", "/data"))
QUEUE_FILE = DATA_DIR / "queue.txt"
PROGRESS_FILE = DATA_DIR / "progress.json"
EVENTS_FILE = DATA_DIR / "events.log"
CONTROL_FILE = DATA_DIR / "control.json"
PORT = int(os.environ.get("HIB_PORT", "8080"))
INSTANCE_ID = os.environ.get("HIB_INSTANCE_ID", str(uuid.uuid4()))
STARTED_AT = time.time()
STATE_LOCK = threading.Lock()
STATE = {
    "instance_id": INSTANCE_ID,
    "progress": 0,
    "last_job": None,
    "processed_sha256": "",
    "quiesced": False,
    "pid": os.getpid(),
    "started_at": STARTED_AT,
}
RUNNING = True


def atomic_write(path, payload):
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(payload, encoding="utf-8")
    os.replace(tmp, path)


def load_progress():
    if PROGRESS_FILE.exists():
        data = json.loads(PROGRESS_FILE.read_text(encoding="utf-8"))
        with STATE_LOCK:
            STATE.update({k: data.get(k, STATE.get(k)) for k in ("progress", "last_job", "processed_sha256")})


def save_progress():
    with STATE_LOCK:
        payload = dict(STATE)
        payload["updated_at"] = time.time()
    atomic_write(PROGRESS_FILE, json.dumps(payload, sort_keys=True, indent=2))


def log_event(event, **fields):
    record = {"event": event, "ts": time.time(), "instance_id": INSTANCE_ID, **fields}
    with EVENTS_FILE.open("a", encoding="utf-8") as stream:
        stream.write(json.dumps(record, sort_keys=True) + "\n")


def set_quiesced(value):
    with STATE_LOCK:
        STATE["quiesced"] = bool(value)
    save_progress()
    log_event("quiesce" if value else "resume")


def control_loop():
    last_mode = None
    while RUNNING:
        mode = "run"
        if CONTROL_FILE.exists():
            data = json.loads(CONTROL_FILE.read_text(encoding="utf-8"))
            mode = data.get("mode", "run")
        if mode != last_mode:
            set_quiesced(mode == "quiesce")
            last_mode = mode
        time.sleep(0.2)


def worker_loop():
    digest = hashlib.sha256()
    while RUNNING:
        with STATE_LOCK:
            quiesced = STATE["quiesced"]
            progress = int(STATE["progress"])
        if quiesced:
            time.sleep(0.2)
            continue
        if not QUEUE_FILE.exists():
            time.sleep(0.2)
            continue
        jobs = QUEUE_FILE.read_text(encoding="utf-8").splitlines()
        if progress >= len(jobs):
            time.sleep(0.2)
            continue
        job = jobs[progress]
        digest.update(job.encode("utf-8") + b"\n")
        time.sleep(0.25)
        with STATE_LOCK:
            STATE["progress"] = progress + 1
            STATE["last_job"] = job
            STATE["processed_sha256"] = digest.hexdigest()
        save_progress()
        log_event("processed", progress=progress + 1, job=job)


class Handler(http.server.BaseHTTPRequestHandler):
    def _send(self, status, payload):
        body = json.dumps(payload, sort_keys=True, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("content-type", "application/json")
        self.send_header("content-length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path not in ("/hib-status", "/healthz"):
            self._send(404, {"error": "not found"})
            return
        with STATE_LOCK:
            payload = dict(STATE)
        payload["queue_size"] = len(QUEUE_FILE.read_text(encoding="utf-8").splitlines()) if QUEUE_FILE.exists() else 0
        payload["uptime_seconds"] = round(time.time() - STARTED_AT, 3)
        payload["progress_file_exists"] = PROGRESS_FILE.exists()
        self._send(200, payload)

    def do_POST(self):
        if self.path == "/quiesce":
            atomic_write(CONTROL_FILE, json.dumps({"mode": "quiesce"}))
            set_quiesced(True)
            self._send(200, {"quiesced": True})
            return
        if self.path == "/resume":
            atomic_write(CONTROL_FILE, json.dumps({"mode": "run"}))
            set_quiesced(False)
            self._send(200, {"quiesced": False})
            return
        self._send(404, {"error": "not found"})

    def log_message(self, fmt, *args):
        return


def handle_signal(signum, frame):
    global RUNNING
    RUNNING = False
    log_event("signal", signum=signum)
    save_progress()
    sys.exit(0)


def main():
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    if not QUEUE_FILE.exists():
        QUEUE_FILE.write_text("\n".join(f"job-{i:05d}" for i in range(1, 10001)) + "\n", encoding="utf-8")
    load_progress()
    log_event("start", pid=os.getpid())
    for sig in (signal.SIGTERM, signal.SIGINT):
        signal.signal(sig, handle_signal)
    threading.Thread(target=control_loop, daemon=True).start()
    threading.Thread(target=worker_loop, daemon=True).start()
    with socketserver.ThreadingTCPServer(("0.0.0.0", PORT), Handler) as httpd:
        httpd.allow_reuse_address = True
        httpd.serve_forever()


if __name__ == "__main__":
    main()
