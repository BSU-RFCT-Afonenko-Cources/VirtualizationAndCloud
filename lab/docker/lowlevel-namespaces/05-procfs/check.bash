#!/bin/bash
source /usr/local/lib/ns-lab/check-common.bash
require_feature pid
f=/home/ubuntu/ns-lab/evidence/05-procfs.json; p=$(live_pid_file /home/ubuntu/ns-lab/state/05-procfs.pid); require_json "$f"
[[ "$(/usr/bin/awk '/^NSpid:/{print $NF}' "/proc/$p/status")" == 1 ]] || fail "процесс не является PID 1"
/usr/bin/nsenter -t "$p" -p -m /usr/bin/mountpoint -q /proc || fail "procfs не смонтирован"
/usr/bin/jq -e '.inner_pid==1 and (.visible_pids|length)>=1 and (.visible_pids|length)<20 and ([.visible_commands[] | test("systemd|dockerd")] | any | not)' "$f" >/dev/null || fail "список процессов не ограничен namespace"
pass "procfs соответствует PID namespace"
