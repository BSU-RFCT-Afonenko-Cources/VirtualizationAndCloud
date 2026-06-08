#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
remove_container
docker rm -f "$DOCKER_NAME" >/dev/null 2>&1 || true
docker image rm oci-lowlevel-lab:local >/dev/null 2>&1 || true
rm -rf "$BUNDLE" "$RUNC_ROOT"
runtime_absent=false
docker_absent=false
bundle_absent=false
runc_cmd state "$CONTAINER_ID" >/dev/null 2>&1 || runtime_absent=true
docker inspect "$DOCKER_NAME" >/dev/null 2>&1 || docker_absent=true
[[ ! -e "$BUNDLE" ]] && bundle_absent=true
jq -n --argjson runtime_absent "$runtime_absent" --argjson docker_absent "$docker_absent" --argjson bundle_absent "$bundle_absent" \
  '{runtime_absent:$runtime_absent,docker_absent:$docker_absent,bundle_absent:$bundle_absent}' > "$EVIDENCE/cleanup.json"
chown ubuntu:ubuntu "$EVIDENCE/cleanup.json"
