#!/bin/bash
source /usr/local/lib/ns-lab/check-common.bash
require_feature user
f=/home/ubuntu/ns-lab/evidence/08-user.json; p=$(live_pid_file /home/ubuntu/ns-lab/state/08-user.pid); require_json "$f"
host_uid=$(/usr/bin/awk '/^Uid:/{print $2}' "/proc/$p/status")
[[ "$host_uid" != 0 ]] || fail "процесс имеет host-root privileges"
/usr/bin/jq -e --argjson p "$p" --argjson uid "$host_uid" '.pid==$p and .inside_uid==0 and .inside_gid==0 and .host_uid==$uid and .host_uid!=0 and (.uid_map|length)>0 and (.gid_map|length)>0' "$f" >/dev/null || fail "UID/GID mapping evidence неверен"
pass "root внутри user namespace не является root хоста"
