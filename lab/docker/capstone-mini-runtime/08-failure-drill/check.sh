#!/bin/bash
set -euo pipefail
source /workspace/VirtualizationAndCloud/lab/docker/capstone-mini-runtime/lib/check-common.sh
require_live_pid
require_file "$EVIDENCE/restart.json"
old_pid=$(json_value "$EVIDENCE/restart.json" old_pid)
new_pid=$(json_value "$EVIDENCE/restart.json" new_pid)
[ "$old_pid" != "$new_pid" ] || fail 'restart reused the same PID'
[ ! -e "/proc/$old_pid" ] || fail 'old runtime process leaked'
[ "$new_pid" = "$(api_pid)" ] || fail 'restart evidence does not identify current API'
[ "$(json_value "$EVIDENCE/restart.json" cleanup_verified)" = True ] || fail 'cleanup_verified is false'
[ "$(json_value "$EVIDENCE/restart.json" restart_verified)" = True ] || fail 'restart_verified is false'
ip link show mrt-host >/dev/null 2>&1 || fail 'network boundary was not recreated'
fetch_api >/dev/null
pass 'controlled cleanup and repeatable restart are proven'
