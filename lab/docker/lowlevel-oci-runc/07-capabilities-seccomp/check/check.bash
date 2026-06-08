#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
pid="$(container_pid)"; [[ "$(container_status)" == running && -d "/proc/$pid" ]]
jq -e '.process.noNewPrivileges == true and (.process.capabilities.effective|length>0) and (.process.capabilities.effective|length<15) and .linux.seccomp' "$BUNDLE/config.json" >/dev/null
grep -Eq '^CapEff:[[:space:]]+[0-9a-fA-F]+' "$EVIDENCE/security-status.txt"
grep -Eq '^Seccomp:[[:space:]]+2$' "$EVIDENCE/security-status.txt"
actual="$(awk '/^Seccomp:/ {print $2}' "/proc/$pid/status")"; [[ "$actual" == 2 ]]
printf 'OK: %s\n' "07-capabilities-seccomp"
