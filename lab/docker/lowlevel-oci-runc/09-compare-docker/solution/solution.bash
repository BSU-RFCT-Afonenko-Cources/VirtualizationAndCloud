#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
build_rootfs
write_config full
start_container
wait_for_heartbeat
docker rm -f "$DOCKER_NAME" >/dev/null 2>&1 || true
tar -C "$ROOTFS" -c . | docker import - oci-lowlevel-lab:local >/dev/null
docker run -d --name "$DOCKER_NAME" --hostname docker-lowlevel --network none oci-lowlevel-lab:local /bin/sh /opt/workload.sh >/dev/null
oci_pid="$(container_pid)"
docker_pid="$(docker inspect -f '{{.State.Pid}}' "$DOCKER_NAME")"
proc_json() {
  local pid="$1"
  jq -n --argjson pid "$pid" \
    --arg args "$(tr '\0' ' ' < "/proc/$pid/cmdline" | sed 's/ $//')" \
    --arg cgroup "$(cat "/proc/$pid/cgroup")" \
    --arg mnt "$(stat -Lc '%i' "/proc/$pid/ns/mnt")" \
    --arg pidns "$(stat -Lc '%i' "/proc/$pid/ns/pid")" \
    --arg uts "$(stat -Lc '%i' "/proc/$pid/ns/uts")" \
    '{pid:$pid,args:$args,cgroup:$cgroup,namespaces:{mnt:$mnt,pid:$pidns,uts:$uts}}'
}
oci="$(proc_json "$oci_pid")"
docker_json="$(proc_json "$docker_pid")"
inspect_id="$(docker inspect -f '{{.Id}}' "$DOCKER_NAME")"
jq -n --argjson oci "$oci" --argjson docker "$docker_json" --arg inspect_id "$inspect_id" '{oci:$oci,docker:($docker + {inspect_id:$inspect_id})}' > "$EVIDENCE/comparison.json"
chown ubuntu:ubuntu "$EVIDENCE/comparison.json"
