#!/bin/bash
source /usr/local/lib/ns-lab/check-common.bash
require_feature uts
f=/home/ubuntu/ns-lab/evidence/02-uts.json; p=$(live_pid_file /home/ubuntu/ns-lab/state/02-uts.pid); require_json "$f"
[[ "$(/bin/hostname)" != "$(/usr/bin/nsenter -t "$p" -u /bin/hostname)" ]] || fail "hostname хоста и namespace совпадают"
[[ "$(/usr/bin/nsenter -t "$p" -u /bin/hostname)" == ns-uts-lab ]] || fail "внутри ожидался hostname ns-uts-lab"
[[ "$(/usr/bin/readlink /proc/1/ns/uts)" != "$(/usr/bin/readlink "/proc/$p/ns/uts")" ]] || fail "UTS namespace не отделён"
/usr/bin/jq -e --argjson p "$p" '.pid==$p and .inside_hostname=="ns-uts-lab" and .inside_uts != .host_uts' "$f" >/dev/null || fail "evidence UTS не соответствует процессу"
pass "UTS namespace и hostname изолированы"
