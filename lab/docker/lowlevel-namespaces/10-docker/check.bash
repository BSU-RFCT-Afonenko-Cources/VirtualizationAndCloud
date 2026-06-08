#!/bin/bash
source /usr/local/lib/ns-lab/check-common.bash
require_feature docker
f=/home/ubuntu/ns-lab/evidence/10-docker.json; require_json "$f"
/usr/bin/docker inspect ns-docker-demo >/dev/null 2>&1 || fail "контейнер ns-docker-demo отсутствует"
running=$(/usr/bin/docker inspect -f '{{.State.Running}}' ns-docker-demo); [[ "$running" == true ]] || fail "контейнер не запущен"
p=$(/usr/bin/docker inspect -f '{{.State.Pid}}' ns-docker-demo); [[ -d "/proc/$p" ]] || fail "host PID контейнера отсутствует"
/usr/bin/jq -e --argjson p "$p" '.container=="ns-docker-demo" and .running==true and .host_pid==$p and (.image|length)>0 and ([.namespaces|keys[]] | length)>=6' "$f" >/dev/null || fail "Docker namespace evidence неверен"
pass "Docker container сопоставлен с host namespaces"
