#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
missing=()
for command_name in runc jq busybox curl; do
  command -v "$command_name" >/dev/null 2>&1 || missing+=("$command_name")
done
if ((${#missing[@]})); then
  apt-get update
  apt-get install -y runc jq busybox-static curl
fi
if ! command -v docker >/dev/null 2>&1; then
  apt-get update
  apt-get install -y docker.io
fi
if ! command -v runc >/dev/null 2>&1 && ! command -v crun >/dev/null 2>&1; then
  echo 'OCI runtime не найден: установите пакет runc или crun из репозитория дистрибутива.' >&2
  exit 1
fi
systemctl enable --now docker >/dev/null 2>&1 || true
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/assets/oci-lab-lib.bash"
ensure_layout
chown -R ubuntu:ubuntu /home/ubuntu/oci-runc-lab
