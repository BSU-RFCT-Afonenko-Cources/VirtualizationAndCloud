#!/bin/bash
set -euo pipefail
source /workspace/VirtualizationAndCloud/lab/docker/capstone-mini-runtime/lib/check-common.sh
require_live_pid
pid=$(api_pid)
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
fetch_api > "$tmp"
python3 - "$tmp" <<'PY'
import json, sys
p=json.load(open(sys.argv[1], encoding='utf-8'))
assert p['service']=='mini-runtime-api'
assert p['hostname']=='mini-runtime'
assert p['pid']==1
assert p['cgroup']=='/mini-runtime'
assert p['limits']=={'memory_max':'134217728','pids_max':'64','cpu_max':'50000 100000'}
assert p['rootfs_marker']=='mini-runtime-rootfs-v1'
assert p['runtime_state_writable'] is True
PY
cmp -s "$tmp" "$EVIDENCE/api.json" || fail 'api evidence is not the current endpoint response'
for ns in uts pid mnt net; do [ "$(readlink "/proc/$pid/ns/$ns")" != "$(readlink "/proc/self/ns/$ns")" ] || fail "$ns isolation regressed"; done
grep -Eq '^CapEff:[[:space:]]+0{16}$' "/proc/$pid/status" || fail 'capabilities regressed'
root_opts=$(findmnt -N "$pid" -n -o OPTIONS --target "$ROOTFS" | head -n1)
[[ ",$root_opts," == *,ro,* ]] || fail 'read-only rootfs policy regressed'
pass 'workload, isolation, limits, rootfs and evidence form one consistent runtime'
