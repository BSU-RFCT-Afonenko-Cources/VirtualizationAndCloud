#!/usr/bin/env bash
set -euo pipefail

LAB_DIR=/home/ubuntu/swarm-resources
API_DIR=/home/ubuntu/swarm-resources/images/api
WORKER_DIR=/home/ubuntu/swarm-resources/images/worker
RESULTS_DIR=/home/ubuntu/swarm-resources/results
EVIDENCE_DIR=/home/ubuntu/swarm-resources/evidence

command -v docker >/dev/null
command -v curl >/dev/null
command -v jq >/dev/null
systemctl is-active --quiet docker

install -d -o ubuntu -g ubuntu /home/ubuntu/swarm-resources
install -d -o ubuntu -g ubuntu /home/ubuntu/swarm-resources/images
install -d -o ubuntu -g ubuntu "$API_DIR" "$WORKER_DIR" "$RESULTS_DIR" "$EVIDENCE_DIR"

cat > "$API_DIR/app.py" <<'PYAPP'
import json
import os
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = json.dumps({
            "service": "swarm-resources-api",
            "hostname": socket.gethostname(),
            "path": self.path,
            "status": "ok",
        }).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print(fmt % args, flush=True)

ThreadingHTTPServer(("0.0.0.0", int(os.getenv("PORT", "8080"))), Handler).serve_forever()
PYAPP

cat > "$API_DIR/Dockerfile" <<'DOCKERFILE'
FROM python:3.12-alpine
WORKDIR /app
COPY app.py /app/app.py
USER 65532:65532
EXPOSE 8080
CMD ["python", "/app/app.py"]
DOCKERFILE

cat > "$WORKER_DIR/worker.py" <<'PYWORKER'
import json
import os
import socket
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

mode = sys.argv[1] if len(sys.argv) > 1 else "serve"
if mode == "serve":
    print(json.dumps({"event": "worker_started", "hostname": socket.gethostname()}), flush=True)
    while True:
        digest = sum(i * i for i in range(25000))
        print(json.dumps({"event": "batch_processed", "digest": digest}), flush=True)
        time.sleep(15)
elif mode == "job":
    slot = os.getenv("TASK_SLOT", "unknown")
    task_id = os.getenv("TASK_ID", "unknown")
    output = {
        "service": "lab-worker-job",
        "task_slot": slot,
        "task_id": task_id,
        "hostname": socket.gethostname(),
        "records_processed": 1000 + int(slot),
        "completed_at": datetime.now(timezone.utc).isoformat(),
    }
    target = Path("/results") / f"worker-{slot}.json"
    target.write_text(json.dumps(output, indent=2) + "\n")
    print(json.dumps(output), flush=True)
else:
    raise SystemExit(f"unsupported mode: {mode}")
PYWORKER

cat > "$WORKER_DIR/Dockerfile" <<'DOCKERFILE'
FROM python:3.12-alpine
WORKDIR /app
COPY worker.py /app/worker.py
ENTRYPOINT ["python", "/app/worker.py"]
CMD ["serve"]
DOCKERFILE

chown -R ubuntu:ubuntu /home/ubuntu/swarm-resources

if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = inactive ]; then
    manager_addr=$(hostname -I | awk '{print $1}')
    [ -n "$manager_addr" ]
    docker swarm init --advertise-addr "$manager_addr" >/dev/null
fi
[ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = active ]
[ "$(docker info --format '{{.Swarm.ControlAvailable}}')" = true ]

docker build --quiet --tag swarm-resources-api:lab "$API_DIR" >/dev/null
docker build --quiet --tag swarm-resources-worker:lab "$WORKER_DIR" >/dev/null

for service in lab-api lab-worker lab-worker-job lab-overcommit; do
    if docker service inspect "$service" >/dev/null 2>&1; then
        docker service rm "$service" >/dev/null
    fi
done
manager_id=$(docker node inspect self --format '{{.ID}}')
docker node update --label-rm swarm_resources "$manager_id" >/dev/null 2>&1 || true
rm -f /home/ubuntu/swarm-resources/results/worker-*.json
rm -f /home/ubuntu/swarm-resources/evidence/overcommit-pending.json
