#!/usr/bin/env bash
set -euo pipefail
cat > /home/ubuntu/capstone-process-hibernation/state-model.json <<'JSON'
{
  "process_memory_assumption": {"contains": ["current queue offset", "in-flight job"], "durability": "RAM until checkpoint"},
  "filesystem_state": {"persistent_path": "/home/ubuntu/capstone-process-hibernation/data", "files": ["queue.txt", "progress.json", "events.log"]},
  "external_dependencies": {"docker": true, "criu_optional": true, "host_port": 18080},
  "endpoint": {"protocol": "http", "path": "/hib-status", "expected_fields": ["progress", "instance_id", "quiesced"]}
}
JSON
chown ubuntu:ubuntu /home/ubuntu/capstone-process-hibernation/state-model.json
