#!/usr/bin/env bash
set -euo pipefail
LAB_DIR=/home/ubuntu/capstone-process-hibernation
ASSET_DIR=/home/ubuntu/capstone-process-hibernation/assets
DATA_DIR=${LAB_DIR}/data
EVIDENCE_DIR=${LAB_DIR}/evidence
BACKUP_DIR=${LAB_DIR}/backups
CHECKPOINT_DIR=${LAB_DIR}/checkpoints
CONTAINER=hib-worker
IMAGE=hib-worker:lab
PORT=18080
status_json() {
  curl -fsS "http://127.0.0.1:${PORT}/hib-status"
}
progress_value() {
  status_json | python3 -c 'import json,sys; print(json.load(sys.stdin).get("progress", -1))'
}
instance_value() {
  status_json | python3 -c 'import json,sys; print(json.load(sys.stdin).get("instance_id", ""))'
}
ensure_dirs() {
  mkdir -p "${LAB_DIR}" "${DATA_DIR}" "${EVIDENCE_DIR}" "${BACKUP_DIR}" "${CHECKPOINT_DIR}" "${LAB_DIR}/src"
}
