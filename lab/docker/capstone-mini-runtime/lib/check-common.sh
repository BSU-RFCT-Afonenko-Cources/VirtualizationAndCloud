#!/bin/bash
set -euo pipefail

LAB=/home/ubuntu/mini-runtime
ROOTFS=$LAB/rootfs
EVIDENCE=$LAB/evidence
CGROUP=/sys/fs/cgroup/mini-runtime
API_PID_FILE=/run/mini-runtime-lab/api.pid
ENDPOINT=http://10.200.0.2:8080/status

fail() { printf 'CHECK FAILED: %s\n' "$*" >&2; exit 1; }
pass() { printf 'CHECK PASSED: %s\n' "$*"; }
require_file() { [ -f "$1" ] || fail "missing file $1"; }
require_dir() { [ -d "$1" ] || fail "missing directory $1"; }
api_pid() { require_file "$API_PID_FILE"; cat "$API_PID_FILE"; }
require_live_pid() { local pid; pid=$(api_pid); kill -0 "$pid" 2>/dev/null || fail "runtime process $pid is not alive"; }
json_value() {
    python3 - "$1" "$2" <<'PY'
import json, sys
value = json.load(open(sys.argv[1], encoding="utf-8"))
parts = sys.argv[2].split(".")
for index, key in enumerate(parts):
    remainder = ".".join(parts[index:])
    if isinstance(value, dict) and remainder in value:
        value = value[remainder]
        break
    value = value[key]
print(value)
PY
}
fetch_api() { curl --noproxy '*' --silent --show-error --fail --max-time 3 "$ENDPOINT"; }
