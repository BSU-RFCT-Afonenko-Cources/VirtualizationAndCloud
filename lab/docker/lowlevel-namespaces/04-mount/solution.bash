#!/bin/bash
set -euo pipefail
f=/home/ubuntu/ns-lab/evidence/04-mount.json; pf=/home/ubuntu/ns-lab/state/04-mount.pid; mp=/home/ubuntu/ns-lab/mnt/private
/usr/bin/unshare --mount /bin/bash -c '/bin/mount --make-rprivate /; /bin/mount -t tmpfs -o size=4m ns-lab-tmpfs /home/ubuntu/ns-lab/mnt/private; exec /usr/local/lib/ns-lab/ns-demo /home/ubuntu/ns-lab/evidence/04-mount-inner.json mount' & p=$!
/usr/bin/printf '%s\n' "$p" > "$pf"; /usr/bin/sleep 1
lines=$(/usr/bin/nsenter -t "$p" -m /bin/cat /proc/self/mountinfo | /bin/grep -F " $mp " | /usr/bin/jq -Rsc 'split("\n")|map(select(length>0))')
/usr/bin/jq -n --argjson pid "$p" --arg mp "$mp" --argjson lines "$lines" '{pid:$pid,mountpoint:$mp,inside_present:true,host_present:false,inside_mountinfo:$lines}' > "$f"; /usr/bin/chown ubuntu:ubuntu "$f" "$pf"
