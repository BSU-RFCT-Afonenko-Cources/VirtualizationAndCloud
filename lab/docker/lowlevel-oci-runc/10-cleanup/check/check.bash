#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
[[ ! -e "$BUNDLE" ]]
! runc_cmd state "$CONTAINER_ID" >/dev/null 2>&1
! docker inspect "$DOCKER_NAME" >/dev/null 2>&1
jq -e '.runtime_absent == true and .docker_absent == true and .bundle_absent == true' "$EVIDENCE/cleanup.json" >/dev/null
printf 'OK: %s\n' "10-cleanup"
