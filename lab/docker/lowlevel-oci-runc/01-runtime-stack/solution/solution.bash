#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
ensure_layout
runtime="$(runtime_bin)"
jq -n \
  --arg docker_path "$(command -v docker)" --arg docker_version "$(docker --version)" \
  --arg containerd_path "$(command -v containerd)" --arg containerd_version "$(containerd --version)" \
  --arg runtime_name "$(basename "$runtime")" --arg runtime_path "$runtime" --arg runtime_version "$($runtime --version | head -n 1)" \
  '{docker:{path:$docker_path,version:$docker_version},containerd:{path:$containerd_path,version:$containerd_version},oci_runtime:{name:$runtime_name,path:$runtime_path,version:$runtime_version}}' > "$EVIDENCE/runtime-stack.json"
chown ubuntu:ubuntu "$EVIDENCE/runtime-stack.json"
