#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSETS="$(readlink -f "$SCRIPT_DIR/../assets")"
install -d -o ubuntu -g ubuntu "$LAB" "$LAB/evidence" "$LAB/api" "$LAB/web"
if [ ! -f "$LAB/compose.yaml" ]; then
  install -o ubuntu -g ubuntu -m 0644 "$ASSETS/compose.yaml" "$LAB/compose.yaml"
  install -o ubuntu -g ubuntu -m 0644 "$ASSETS/api/Dockerfile" "$LAB/api/Dockerfile"
  install -o ubuntu -g ubuntu -m 0644 "$ASSETS/api/requirements.txt" "$LAB/api/requirements.txt"
  install -o ubuntu -g ubuntu -m 0644 "$ASSETS/api/app.py" "$LAB/api/app.py"
  install -o ubuntu -g ubuntu -m 0644 "$ASSETS/web/default.conf.template" "$LAB/web/default.conf.template"
fi
chown -R ubuntu:ubuntu "$LAB"
