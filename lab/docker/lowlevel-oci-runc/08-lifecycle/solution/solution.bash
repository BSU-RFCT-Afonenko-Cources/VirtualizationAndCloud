#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
remove_container
write_config full
transitions='[]'
runc_cmd create --bundle "$BUNDLE" "$CONTAINER_ID"
state="$(runc_cmd state "$CONTAINER_ID")"
transitions="$(jq --argjson state "$state" '. + [{stage:"create",status:$state.status,state:$state}]' <<< "$transitions")"
runc_cmd start "$CONTAINER_ID"
state="$(runc_cmd state "$CONTAINER_ID")"
transitions="$(jq --argjson state "$state" '. + [{stage:"start",status:$state.status,state:$state}]' <<< "$transitions")"
runc_cmd kill "$CONTAINER_ID" KILL
for _ in $(seq 1 30); do
  state="$(runc_cmd state "$CONTAINER_ID" 2>/dev/null || true)"
  [[ "$(jq -r '.status // empty' <<< "$state" 2>/dev/null)" == stopped ]] && break
  sleep 0.1
done
transitions="$(jq --argjson state "$state" '. + [{stage:"kill",status:$state.status,state:$state}]' <<< "$transitions")"
runc_cmd delete "$CONTAINER_ID"
transitions="$(jq '. + [{stage:"delete",status:"deleted"}]' <<< "$transitions")"
jq -n --argjson transitions "$transitions" '{transitions:$transitions}' > "$EVIDENCE/lifecycle.json"
chown ubuntu:ubuntu "$EVIDENCE/lifecycle.json"
