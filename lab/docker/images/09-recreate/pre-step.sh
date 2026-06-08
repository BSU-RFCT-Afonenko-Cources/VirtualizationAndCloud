#!/usr/bin/env bash
set -euo pipefail

STATE_DIR=/var/lib/image-lab
install -d -m 0755 "$STATE_DIR"
docker container inspect --format '{{.Id}}' image-lab-api > "$STATE_DIR/previous-container-id"
