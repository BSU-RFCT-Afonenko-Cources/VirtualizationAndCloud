#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
pid="$(container_pid)"; [[ "$(container_status)" == running && -d "/proc/$pid" ]]
for type in mount uts pid; do jq -e --arg type "$type" '[.linux.namespaces[] | select(.type==$type)] | length==1' "$BUNDLE/config.json" >/dev/null; done
for ns in mnt uts pid; do
  jq -e --arg ns "$ns" '.[$ns].host and .[$ns].container and (.[$ns].host != .[$ns].container)' "$EVIDENCE/namespaces.json" >/dev/null
  [[ "$(jq -r --arg ns "$ns" '.[$ns].container' "$EVIDENCE/namespaces.json")" == "$(stat -Lc '%i' "/proc/$pid/ns/$ns")" ]]
done
printf 'OK: %s\n' "05-namespaces"
