#!/bin/bash
set -euo pipefail
f=/home/ubuntu/ns-lab/evidence/02-uts.json; pf=/home/ubuntu/ns-lab/state/02-uts.pid
/usr/bin/unshare --uts /bin/bash -c '/bin/hostname ns-uts-lab; exec /usr/local/lib/ns-lab/ns-demo /home/ubuntu/ns-lab/evidence/02-uts-inner.json uts' & p=$!
/usr/bin/printf '%s\n' "$p" > "$pf"; /usr/bin/sleep 1
/usr/bin/jq -n --argjson pid "$p" --arg inside_hostname "$(/usr/bin/nsenter -t "$p" -u /bin/hostname)" --arg host_hostname "$(/bin/hostname)" --arg inside_uts "$(/usr/bin/readlink "/proc/$p/ns/uts")" --arg host_uts "$(/usr/bin/readlink /proc/1/ns/uts)" '{pid:$pid,inside_hostname:$inside_hostname,host_hostname:$host_hostname,inside_uts:$inside_uts,host_uts:$host_uts}' > "$f"
/usr/bin/chown ubuntu:ubuntu "$f" "$pf"
