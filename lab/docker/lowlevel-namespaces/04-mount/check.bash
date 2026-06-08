#!/bin/bash
source /usr/local/lib/ns-lab/check-common.bash
require_feature mount
f=/home/ubuntu/ns-lab/evidence/04-mount.json; p=$(live_pid_file /home/ubuntu/ns-lab/state/04-mount.pid); require_json "$f"
/usr/bin/nsenter -t "$p" -m /usr/bin/mountpoint -q /home/ubuntu/ns-lab/mnt/private || fail "mount отсутствует внутри namespace"
/usr/bin/mountpoint -q /home/ubuntu/ns-lab/mnt/private && fail "mount распространился на хост"
/usr/bin/jq -e '.mountpoint=="/home/ubuntu/ns-lab/mnt/private" and .inside_present==true and .host_present==false and (.inside_mountinfo|length)>0' "$f" >/dev/null || fail "evidence mountinfo неверен"
pass "таблица монтирования изолирована"
