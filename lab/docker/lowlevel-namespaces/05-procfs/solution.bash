#!/bin/bash
set -euo pipefail
f=/home/ubuntu/ns-lab/evidence/05-procfs.json; pf=/home/ubuntu/ns-lab/state/05-procfs.pid
/usr/bin/unshare --pid --fork --mount --mount-proc /usr/local/lib/ns-lab/ns-demo /home/ubuntu/ns-lab/evidence/05-procfs-inner.json procfs & launcher=$!
/usr/bin/sleep 1; p=$(/usr/bin/pgrep -P "$launcher" | /usr/bin/head -n1); [[ -n "$p" ]] || p="$launcher"; /usr/bin/printf '%s\n' "$p" > "$pf"
rows=$(/usr/bin/nsenter -t "$p" -p -m /bin/ps -e -o pid=,comm= --no-headers)
pids=$(/usr/bin/printf '%s\n' "$rows" | /usr/bin/awk '{print $1}' | /usr/bin/jq -Rsc 'split("\n")|map(select(length>0)|tonumber)'); cmds=$(/usr/bin/printf '%s\n' "$rows" | /usr/bin/awk '{print $2}' | /usr/bin/jq -Rsc 'split("\n")|map(select(length>0))')
/usr/bin/jq -n --argjson outer "$p" --argjson pids "$pids" --argjson cmds "$cmds" '{outer_pid:$outer,inner_pid:1,proc_mount:"/proc",visible_pids:$pids,visible_commands:$cmds}' > "$f"; /usr/bin/chown ubuntu:ubuntu "$f" "$pf"
