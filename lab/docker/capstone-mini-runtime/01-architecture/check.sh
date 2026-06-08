#!/bin/bash
set -euo pipefail
source /workspace/VirtualizationAndCloud/lab/docker/capstone-mini-runtime/lib/check-common.sh
SPEC=$LAB/mini-runtime-spec.yaml
require_file "$SPEC"
for key in version rootfs namespaces cgroups mounts network workload; do
    grep -Eq "^${key}:" "$SPEC" || fail "spec misses top-level field $key"
done
for value in '/home/ubuntu/mini-runtime/rootfs' '/sys/fs/cgroup/mini-runtime' 'mini-runtime-api' 'mini-runtime' '10.200.0.2/30' 'http://10.200.0.2:8080/status' '65534'; do
    grep -Fq "$value" "$SPEC" || fail "spec misses required value $value"
done
for namespace in uts pid mount network; do
    grep -Eq "^[[:space:]]*-[[:space:]]+$namespace$" "$SPEC" || fail "spec misses $namespace namespace"
done
grep -Eq '^[[:space:]]+readonly:[[:space:]]+true$' "$SPEC" || fail 'rootfs must be declared read-only'
pass 'runtime specification has the required machine-readable contract'
