#!/bin/bash
set -euo pipefail

LAB_ROOT=/home/ubuntu/mini-runtime
ASSET_ROOT=/usr/local/lib/mini-runtime-lab
SOURCE_ROOT=/workspace/VirtualizationAndCloud/lab/docker/capstone-mini-runtime

install -d -o ubuntu -g ubuntu -m 0755 "$LAB_ROOT" "$LAB_ROOT/evidence" "$LAB_ROOT/runtime-state"
install -d -o root -g root -m 0755 "$ASSET_ROOT"
install -o root -g root -m 0755 "$SOURCE_ROOT/assets/mini-runtime-api.py" "$ASSET_ROOT/mini-runtime-api.py"
install -o root -g root -m 0755 "$SOURCE_ROOT/assets/reference-runtime.sh" "$ASSET_ROOT/reference-runtime.sh"
install -o root -g root -m 0644 "$SOURCE_ROOT/assets/spec-template.yaml" "$ASSET_ROOT/spec-template.yaml"
chown -R ubuntu:ubuntu "$LAB_ROOT"
