#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
pid="$(container_pid)"; [[ "$(container_status)" == running && -d "/proc/$pid" ]]
jq -e '.linux.resources.memory.limit > 0 and .linux.resources.cpu.quota > 0 and .linux.resources.cpu.period > .linux.resources.cpu.quota' "$BUNDLE/config.json" >/dev/null
jq -e --argjson pid "$pid" '.pid==$pid and (.version==1 or .version==2) and (.path|length>0)' "$EVIDENCE/cgroup.json" >/dev/null
if [[ "$(jq -r '.version' "$EVIDENCE/cgroup.json")" == 2 ]]; then
  jq -e '.memory_max != "max" and (.memory_max|tonumber)>0 and (.cpu_max|split(" ")|.[0]|tonumber)>0' "$EVIDENCE/cgroup.json" >/dev/null
fi
printf 'OK: %s\n' "06-cgroups"
