#!/bin/bash
set -euo pipefail
source /workspace/VirtualizationAndCloud/lab/docker/capstone-mini-runtime/lib/check-common.sh
require_live_pid
pid=$(api_pid)
for ns in uts pid mnt net; do
    [ "$(readlink "/proc/$pid/ns/$ns")" != "$(readlink "/proc/self/ns/$ns")" ] || fail "$ns namespace is shared with host"
done
[ "$(nsenter -t "$pid" -u hostname)" = mini-runtime ] || fail 'isolated hostname is incorrect'
awk '/^NSpid:/ {exit !($NF == 1 && NF >= 3)}' "/proc/$pid/status" || fail 'API does not see itself as PID 1'
[ "$(cat "/proc/$pid/root/.mini-runtime-rootfs")" = mini-runtime-rootfs-v1 ] || fail 'API does not use the prepared rootfs'
findmnt -N "$pid" -n -o TARGET --target "$ROOTFS" | grep -Fxq "$ROOTFS" || fail 'rootfs bind mount is absent from API mount namespace'
pass 'UTS, PID, mount and network namespaces are isolated'
