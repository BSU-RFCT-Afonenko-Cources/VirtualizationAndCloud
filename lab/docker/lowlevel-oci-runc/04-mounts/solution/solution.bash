#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
write_config mounts
start_container
wait_for_heartbeat
pid="$(container_pid)"
cat "/proc/$pid/mountinfo" > "$EVIDENCE/mountinfo.txt"
chown ubuntu:ubuntu "$EVIDENCE/mountinfo.txt"
save_runtime_state
