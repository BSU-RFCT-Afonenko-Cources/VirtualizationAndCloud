#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
jq -e '[.transitions[].status] | index("created") and index("running") and index("stopped") and index("deleted")' "$EVIDENCE/lifecycle.json" >/dev/null
! runc_cmd state "$CONTAINER_ID" >/dev/null 2>&1
printf 'OK: %s\n' "08-lifecycle"
