#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
PIDFILE="$LAB/run/host.pid"; FILE="$STATE/host/state.json"; CG=/sys/fs/cgroup/cr-demo-counter
need_file "$PIDFILE"; need_file "$FILE"; pid=$(/bin/cat "$PIDFILE")
/bin/kill -0 "$pid" 2>/dev/null || fail "host counter is not alive"
test -f /sys/fs/cgroup/cgroup.controllers || fail "this exercise requires writable cgroup v2"
/usr/bin/mkdir -p "$CG"
printf '%s\n' "$pid" >"$CG/cgroup.procs"
artifacts_before=$(/usr/bin/find "$CHECKPOINTS" -type f 2>/dev/null | /usr/bin/wc -l)
printf '1\n' >"$CG/cgroup.freeze"
for _ in $(/usr/bin/seq 1 20); do /bin/grep -q 'frozen 1' "$CG/cgroup.events" && break; /bin/sleep 0.1; done
frozen=$(/bin/cat "$CG/cgroup.freeze"); before=$(state_counter "$FILE"); /bin/sleep 2; during=$(state_counter "$FILE")
printf '0\n' >"$CG/cgroup.freeze"
for _ in $(/usr/bin/seq 1 30); do after=$(state_counter "$FILE"); test "$after" -gt "$during" && break; /bin/sleep 0.1; done
artifacts_after=$(/usr/bin/find "$CHECKPOINTS" -type f 2>/dev/null | /usr/bin/wc -l); artifacts=$((artifacts_after-artifacts_before))
/usr/bin/python3 - "$pid" "$CG" "$frozen" "$before" "$during" "$after" "$artifacts" <<'PY'
import json,sys
x={'pid':int(sys.argv[1]),'cgroup':sys.argv[2],'frozen_state':int(sys.argv[3]),'counter_before':int(sys.argv[4]),'counter_during':int(sys.argv[5]),'counter_after':int(sys.argv[6]),'checkpoint_files_created':int(sys.argv[7])}
json.dump(x,open('/home/ubuntu/cr-lab/evidence/freeze.json','w'),indent=2)
PY
lab_owner
