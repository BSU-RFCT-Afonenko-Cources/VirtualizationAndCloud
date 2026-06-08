#!/bin/bash
set -euo pipefail
source /workspace/VirtualizationAndCloud/lab/docker/capstone-mini-runtime/lib/check-common.sh
require_live_pid
pid=$(api_pid)
awk '/^Uid:/ {exit !($2 == 65534 && $3 == 65534)}' "/proc/$pid/status" || fail 'API UID is not 65534'
awk '/^Gid:/ {exit !($2 == 65534 && $3 == 65534)}' "/proc/$pid/status" || fail 'API GID is not 65534'
awk '/^CapEff:/ {exit !($2 == "0000000000000000")}' "/proc/$pid/status" || fail 'effective capabilities are not empty'
awk '/^CapBnd:/ {exit !($2 == "0000000000000000")}' "/proc/$pid/status" || fail 'bounding capabilities are not empty'
awk '/^NoNewPrivs:/ {exit !($2 == 1)}' "/proc/$pid/status" || fail 'no_new_privs is disabled'
root_opts=$(findmnt -N "$pid" -n -o OPTIONS --target "$ROOTFS" | head -n1)
[[ ",$root_opts," == *,ro,* ]] || fail 'runtime root mount is not read-only'
require_file "$EVIDENCE/privileges.json"
[ "$(json_value "$EVIDENCE/privileges.json" CapEff)" = 0000000000000000 ] || fail 'privilege evidence is stale'
pass 'workload runs unprivileged with a read-only rootfs'
