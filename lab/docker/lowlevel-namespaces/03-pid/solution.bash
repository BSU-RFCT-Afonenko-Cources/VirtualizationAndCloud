#!/bin/bash
set -euo pipefail
f=/home/ubuntu/ns-lab/evidence/03-pid.json; pf=/home/ubuntu/ns-lab/state/03-pid.pid
/usr/bin/unshare --pid --fork --mount-proc /usr/local/lib/ns-lab/ns-demo /home/ubuntu/ns-lab/evidence/03-pid-inner.json pid & launcher=$!
/usr/bin/sleep 1; p=$(/usr/bin/pgrep -P "$launcher" | /usr/bin/head -n1); [[ -n "$p" ]] || p="$launcher"; /usr/bin/printf '%s\n' "$p" > "$pf"
nspid=$(/usr/bin/awk '/^NSpid:/{for(i=2;i<=NF;i++) printf "%s%s",$i,(i<NF?",":"")}' "/proc/$p/status")
visible=$(/usr/bin/nsenter -t "$p" -p -m /bin/ps -e -o pid=,comm= --no-headers | /usr/bin/jq -Rsc 'split("\n")|map(select(length>0))')
/usr/bin/jq -n --argjson outer "$p" --arg nspid "$nspid" --argjson visible "$visible" '{outer_pid:$outer,inner_pid:1,nspid:($nspid|split(",")|map(tonumber)),visible_processes:$visible}' > "$f"; /usr/bin/chown ubuntu:ubuntu "$f" "$pf"
