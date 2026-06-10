#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
pid="$(container_pid)"; [[ "$(container_status)" == running && -d "/proc/$pid" ]]
jq -e '[.mounts[] | select(.destination=="/proc" and .type=="proc")] | length==1' "$BUNDLE/config.json" >/dev/null
jq -e '[.mounts[] | select(.destination=="/home/ubuntu/oci-runc-lab/tmp" and .type=="tmpfs")] | length==1' "$BUNDLE/config.json" >/dev/null
jq -e '[.mounts[] | select(.destination=="/data" and .type=="bind" and .source=="/home/ubuntu/oci-runc-lab/shared")] | length==1' "$BUNDLE/config.json" >/dev/null
[[ -s "$EVIDENCE/mountinfo.txt" ]]
awk '$5=="/home/ubuntu/oci-runc-lab/tmp" {ok=1} END{exit !ok}' "$EVIDENCE/mountinfo.txt"
awk '$5=="/data" {ok=1} END{exit !ok}' "$EVIDENCE/mountinfo.txt"
printf 'OK: %s\n' "04-mounts"
