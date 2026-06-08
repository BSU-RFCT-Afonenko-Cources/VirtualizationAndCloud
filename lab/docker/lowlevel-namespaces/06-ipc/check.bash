#!/bin/bash
source /usr/local/lib/ns-lab/check-common.bash
require_feature ipc
f=/home/ubuntu/ns-lab/evidence/06-ipc.json; p=$(live_pid_file /home/ubuntu/ns-lab/state/06-ipc.pid); require_json "$f"
qid=$(/usr/bin/jq -r '.queue_id' "$f")
/usr/bin/nsenter -t "$p" -i /usr/bin/ipcs -q | /bin/grep -Eq "[[:space:]]$qid[[:space:]]" || fail "очередь не видна внутри IPC namespace"
/usr/bin/ipcs -q | /bin/grep -Eq "[[:space:]]$qid[[:space:]]" && fail "очередь видна на хосте"
/usr/bin/jq -e '.inside_visible==true and .host_visible==false and (.ipc_handle|test("^ipc:\\[[0-9]+\\]$"))' "$f" >/dev/null || fail "evidence IPC неверен"
pass "System V IPC object изолирован"
