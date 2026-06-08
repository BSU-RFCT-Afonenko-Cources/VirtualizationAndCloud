#!/bin/bash
set -euo pipefail
source /workspace/VirtualizationAndCloud/lab/docker/capstone-mini-runtime/lib/check-common.sh
require_live_pid
pid=$(api_pid)
for file in runtime.json resources.json privileges.json network.json mounts.txt api.json; do require_file "$EVIDENCE/$file"; done
[ "$(json_value "$EVIDENCE/runtime.json" pid)" = "$pid" ] || fail 'runtime evidence PID is stale'
[ "$(json_value "$EVIDENCE/runtime.json" hostname)" = mini-runtime ] || fail 'runtime evidence hostname mismatch'
for ns in uts pid mnt net; do
    [ "$(json_value "$EVIDENCE/runtime.json" namespaces.$ns)" = "$(readlink "/proc/$pid/ns/$ns")" ] || fail "$ns evidence is stale"
done
cmp -s "$EVIDENCE/mounts.txt" "/proc/$pid/mountinfo" || fail 'mount evidence differs from live mountinfo'
require_file "$LAB/runtime-state/api.log"
python3 -m json.tool "$EVIDENCE/api.json" >/dev/null || fail 'api evidence is not valid JSON'
pass 'evidence pack matches the live runtime'
