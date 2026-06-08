#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
file="$EVIDENCE/runtime-stack.json"
jq -e '.docker.path and .docker.version and .containerd.path and .containerd.version and (.oci_runtime.name == "runc" or .oci_runtime.name == "crun") and .oci_runtime.path and .oci_runtime.version' "$file" >/dev/null
[[ -x "$(jq -r '.docker.path' "$file")" && -x "$(jq -r '.containerd.path' "$file")" && -x "$(jq -r '.oci_runtime.path' "$file")" ]]
printf 'OK: %s\n' "01-runtime-stack"
