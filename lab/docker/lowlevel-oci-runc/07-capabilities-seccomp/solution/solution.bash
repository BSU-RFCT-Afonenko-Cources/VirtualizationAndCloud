#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
write_config security
start_container
wait_for_heartbeat
pid="$(container_pid)"
awk '/^(Cap(Inh|Prm|Eff|Bnd|Amb)|Seccomp|Seccomp_filters):/' "/proc/$pid/status" > "$EVIDENCE/security-status.txt"
chown ubuntu:ubuntu "$EVIDENCE/security-status.txt"
