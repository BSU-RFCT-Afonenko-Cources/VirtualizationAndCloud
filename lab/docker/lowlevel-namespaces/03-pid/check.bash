#!/bin/bash
source /usr/local/lib/ns-lab/check-common.bash
require_feature pid
f=/home/ubuntu/ns-lab/evidence/03-pid.json; p=$(live_pid_file /home/ubuntu/ns-lab/state/03-pid.pid); require_json "$f"
nspid=$(/usr/bin/awk '/^NSpid:/{print $NF}' "/proc/$p/status")
[[ "$nspid" == 1 ]] || fail "первый процесс имеет внутренний PID $nspid вместо 1"
/usr/bin/jq -e --argjson p "$p" '.outer_pid==$p and .inner_pid==1 and (.nspid|last)==1 and (.visible_processes|length)>=1' "$f" >/dev/null || fail "evidence PID namespace неполон"
pass "процесс PID namespace выполняет роль PID 1"
