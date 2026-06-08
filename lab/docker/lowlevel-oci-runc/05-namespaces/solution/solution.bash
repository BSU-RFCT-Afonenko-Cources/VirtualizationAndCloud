#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
write_config namespaces
start_container
wait_for_heartbeat
pid="$(container_pid)"
json='{}'
for ns in mnt uts pid; do
  host="$(stat -Lc '%i' "/proc/1/ns/$ns")"
  container="$(stat -Lc '%i' "/proc/$pid/ns/$ns")"
  json="$(jq --arg ns "$ns" --argjson host "$host" --argjson container "$container" '. + {($ns):{host:$host,container:$container}}' <<< "$json")"
done
jq --argjson pid "$pid" '. + {pid:$pid}' <<< "$json" > "$EVIDENCE/namespaces.json"
chown ubuntu:ubuntu "$EVIDENCE/namespaces.json"
