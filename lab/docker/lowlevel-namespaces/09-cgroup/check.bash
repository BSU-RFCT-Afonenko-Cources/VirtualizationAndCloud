#!/bin/bash
source /usr/local/lib/ns-lab/check-common.bash
f=/home/ubuntu/ns-lab/evidence/09-cgroup.json; require_json "$f"
status=$(/usr/bin/jq -r '.status' "$f")
if [[ "$status" == unavailable ]]; then
  [[ "$(feature_status cgroup)" == unavailable ]] || fail "cgroup namespace доступен, unavailable не принимается"
  /usr/bin/jq -e '(.reason|length)>0' "$f" >/dev/null || fail "нет причины недоступности"
  pass "недоступность cgroup namespace корректно зафиксирована"; exit 0
fi
p=$(live_pid_file /home/ubuntu/ns-lab/state/09-cgroup.pid)
[[ "$(/usr/bin/readlink /proc/1/ns/cgroup)" != "$(/usr/bin/readlink "/proc/$p/ns/cgroup")" ]] || fail "cgroup namespace не отделён"
/usr/bin/jq -e --argjson p "$p" '.status=="supported" and .pid==$p and (.host_cgroup|length)>0 and (.inside_cgroup|length)>0 and .host_handle != .inside_handle' "$f" >/dev/null || fail "cgroup evidence неверен"
pass "cgroup view изолирован"
