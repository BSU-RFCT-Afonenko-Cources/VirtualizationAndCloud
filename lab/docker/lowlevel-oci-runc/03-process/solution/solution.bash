#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
build_rootfs
write_config process
start_container
wait_for_heartbeat
save_runtime_state
