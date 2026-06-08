#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
write_config cgroups
start_container
wait_for_heartbeat
pid="$(container_pid)"
if [[ -f /sys/fs/cgroup/cgroup.controllers ]]; then
  path="$(awk -F: '$1=="0" {print $3}' "/proc/$pid/cgroup")"
  base="/sys/fs/cgroup$path"
  jq -n --argjson pid "$pid" --arg path "$path" --arg memory "$(cat "$base/memory.max")" --arg cpu "$(cat "$base/cpu.max")" \
    '{pid:$pid,version:2,path:$path,memory_max:$memory,cpu_max:$cpu}' > "$EVIDENCE/cgroup.json"
else
  memory_path="$(awk -F: '$2 ~ /memory/ {print $3}' "/proc/$pid/cgroup")"
  cpu_path="$(awk -F: '$2 ~ /cpu/ {print $3; exit}' "/proc/$pid/cgroup")"
  jq -n --argjson pid "$pid" --arg path "$memory_path" \
    --arg memory "$(cat "/sys/fs/cgroup/memory$memory_path/memory.limit_in_bytes")" \
    --arg quota "$(cat "/sys/fs/cgroup/cpu$cpu_path/cpu.cfs_quota_us")" \
    --arg period "$(cat "/sys/fs/cgroup/cpu$cpu_path/cpu.cfs_period_us")" \
    '{pid:$pid,version:1,path:$path,memory_limit:$memory,cpu_quota:$quota,cpu_period:$period}' > "$EVIDENCE/cgroup.json"
fi
chown ubuntu:ubuntu "$EVIDENCE/cgroup.json"
