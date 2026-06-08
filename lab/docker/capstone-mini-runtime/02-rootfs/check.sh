#!/bin/bash
set -euo pipefail
source /workspace/VirtualizationAndCloud/lab/docker/capstone-mini-runtime/lib/check-common.sh
require_dir "$ROOTFS"
for path in proc sys/fs/cgroup run/mini-runtime opt/mini-runtime; do require_dir "$ROOTFS/$path"; done
require_file "$ROOTFS/opt/mini-runtime/mini-runtime-api.py"
require_file "$ROOTFS/.mini-runtime-rootfs"
[ "$(cat "$ROOTFS/.mini-runtime-rootfs")" = mini-runtime-rootfs-v1 ] || fail 'incorrect rootfs marker'
[ -x "$ROOTFS/opt/mini-runtime/mini-runtime-api.py" ] || fail 'API is not executable'
[ -x "$ROOTFS/usr/bin/python3" ] || fail 'Python runtime is absent'
if find "$ROOTFS" -xdev \( -type f -o -type d \) -perm /0222 -print -quit | grep -q .; then fail 'base rootfs contains writable objects'; fi
require_dir "$LAB/runtime-state"
[ "$(stat -c %u:%g "$LAB/runtime-state")" = 65534:65534 ] || fail 'runtime-state owner must be 65534:65534'
[ -w "$LAB/runtime-state" ] || fail 'runtime-state is not writable by checker/root'
pass 'immutable base rootfs and separate writable state are prepared'
