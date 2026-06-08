#!/bin/bash
set -euo pipefail
source /workspace/VirtualizationAndCloud/lab/docker/capstone-mini-runtime/lib/check-common.sh
require_live_pid
pid=$(api_pid)
require_dir "$CGROUP"
[ "$(cat "$CGROUP/memory.max")" = 134217728 ] || fail 'memory.max mismatch'
[ "$(cat "$CGROUP/pids.max")" = 64 ] || fail 'pids.max mismatch'
[ "$(cat "$CGROUP/cpu.max")" = '50000 100000' ] || fail 'cpu.max mismatch'
grep -Eq '^0::/mini-runtime$' "/proc/$pid/cgroup" || fail 'API is not a member of /mini-runtime cgroup'
grep -qx "$pid" "$CGROUP/cgroup.procs" || fail 'API PID is absent from cgroup.procs'
require_file "$EVIDENCE/resources.json"
[ "$(json_value "$EVIDENCE/resources.json" memory.max)" = 134217728 ] || fail 'resource evidence is stale'
fetch_api >/dev/null
pass 'cgroup v2 limits are applied to the live API'
