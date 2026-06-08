#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
[[ "$(container_status)" == running ]]
[[ "$(docker inspect -f '{{.State.Running}}' "$DOCKER_NAME")" == true ]]
oci_pid="$(container_pid)"; docker_pid="$(docker inspect -f '{{.State.Pid}}' "$DOCKER_NAME")"
jq -e --argjson op "$oci_pid" --argjson dp "$docker_pid" '.oci.pid==$op and .docker.pid==$dp and (.oci.args|length>0) and (.docker.args|length>0) and (.oci.cgroup|length>0) and (.docker.cgroup|length>0) and .oci.namespaces.mnt and .docker.namespaces.mnt' "$EVIDENCE/comparison.json" >/dev/null
[[ "$(jq -r '.docker.inspect_id' "$EVIDENCE/comparison.json")" == "$(docker inspect -f '{{.Id}}' "$DOCKER_NAME")" ]]
printf 'OK: %s\n' "09-compare-docker"
