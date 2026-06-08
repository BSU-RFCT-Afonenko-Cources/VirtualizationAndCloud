#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
[[ "$(container_status)" == running ]]
pid="$(container_pid)"
[[ "$pid" =~ ^[0-9]+$ && -d "/proc/$pid" ]]
jq -e '.process.terminal == false and .process.cwd and (.process.args | index("/opt/workload.sh"))' "$BUNDLE/config.json" >/dev/null
[[ -s "/proc/$pid/root/run/oci-lab/heartbeat" ]]
now="$(date +%s)"; heartbeat="$(cat "/proc/$pid/root/run/oci-lab/heartbeat")"; (( now - heartbeat < 8 ))
jq -e --argjson pid "$pid" '.status == "running" and .pid == $pid' "$EVIDENCE/runc-state.json" >/dev/null
printf 'OK: %s\n' "03-process"
