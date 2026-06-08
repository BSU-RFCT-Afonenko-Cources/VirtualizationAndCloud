#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
PIDFILE="$LAB/run/host.pid"; FILE="$STATE/host/state.json"
need_file "$PIDFILE"; need_file "$FILE"; pid=$(/bin/cat "$PIDFILE")
/bin/kill -0 "$pid" 2>/dev/null || fail "host counter is not alive"
/bin/grep -q '^Name:[[:space:]]*cr-demo-counter' "/proc/$pid/status" || fail "unexpected process name"
a=$(state_counter "$FILE"); /bin/sleep 2; b=$(state_counter "$FILE")
test "$b" -gt "$a" || fail "counter did not increase"
/usr/bin/python3 - "$FILE" <<'PY'
import json,sys,time,os
x=json.load(open(sys.argv[1])); assert x['session'] and x['starts']>=1 and x['pid']>0
assert time.time()-os.path.getmtime(sys.argv[1]) < 5
PY
pass "live cr-demo-counter advanced from $a to $b"
