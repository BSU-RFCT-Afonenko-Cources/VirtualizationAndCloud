#!/usr/bin/env bash
set -euo pipefail

STATE_DIR=/home/ubuntu/image-lab/state
install -d -m 0755 "$STATE_DIR"
docker container inspect --format '{{.Id}}' image-lab-api > "$STATE_DIR/previous-container-id"
