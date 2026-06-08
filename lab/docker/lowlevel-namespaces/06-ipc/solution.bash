#!/bin/bash
set -euo pipefail
f=/home/ubuntu/ns-lab/evidence/06-ipc.json; pf=/home/ubuntu/ns-lab/state/06-ipc.pid
/usr/bin/unshare --ipc /bin/bash -c 'qid=$(/usr/bin/ipcmk -Q | /usr/bin/awk "{print \$NF}"); /usr/bin/printf "%s\n" "$qid" > /home/ubuntu/ns-lab/state/06-ipc.qid; exec /usr/local/lib/ns-lab/ns-demo /home/ubuntu/ns-lab/evidence/06-ipc-inner.json ipc' & p=$!
/usr/bin/printf '%s\n' "$p" > "$pf"; /usr/bin/sleep 1; qid=$(/usr/bin/cat /home/ubuntu/ns-lab/state/06-ipc.qid)
/usr/bin/jq -n --argjson pid "$p" --arg handle "$(/usr/bin/readlink "/proc/$p/ns/ipc")" --argjson qid "$qid" '{pid:$pid,ipc_handle:$handle,queue_id:$qid,inside_visible:true,host_visible:false}' > "$f"; /usr/bin/chown ubuntu:ubuntu "$f" "$pf" /home/ubuntu/ns-lab/state/06-ipc.qid
