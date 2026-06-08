#!/bin/bash
set -euo pipefail
f=/home/ubuntu/ns-lab/evidence/09-cgroup.json; pf=/home/ubuntu/ns-lab/state/09-cgroup.pid
if [[ "$(/usr/bin/jq -r '.features.cgroup.status' /home/ubuntu/ns-lab/capabilities.json)" != supported ]]; then reason=$(/usr/bin/jq -r '.features.cgroup.reason' /home/ubuntu/ns-lab/capabilities.json); /usr/bin/jq -n --arg reason "$reason" '{status:"unavailable",reason:$reason}' > "$f"; /usr/bin/chown ubuntu:ubuntu "$f"; exit 0; fi
/usr/bin/unshare --cgroup /usr/local/lib/ns-lab/ns-demo /home/ubuntu/ns-lab/evidence/09-cgroup-inner.json cgroup & p=$!; /usr/bin/printf '%s\n' "$p" > "$pf"; /usr/bin/sleep 1
inside=$(/usr/bin/nsenter -t "$p" -C /bin/cat /proc/self/cgroup | /usr/bin/jq -Rsc 'split("\n")|map(select(length>0))'); host=$(/bin/cat /proc/1/cgroup | /usr/bin/jq -Rsc 'split("\n")|map(select(length>0))')
/usr/bin/jq -n --argjson pid "$p" --argjson host "$host" --argjson inside "$inside" --arg hh "$(/usr/bin/readlink /proc/1/ns/cgroup)" --arg ih "$(/usr/bin/readlink "/proc/$p/ns/cgroup")" '{status:"supported",pid:$pid,host_cgroup:$host,inside_cgroup:$inside,host_handle:$hh,inside_handle:$ih}' > "$f"; /usr/bin/chown ubuntu:ubuntu "$f" "$pf"
