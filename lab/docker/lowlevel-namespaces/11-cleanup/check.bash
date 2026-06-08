#!/bin/bash
source /usr/local/lib/ns-lab/check-common.bash
f=/home/ubuntu/ns-lab-cleanup.json; require_json "$f"
[[ ! -e /home/ubuntu/ns-lab ]] || fail "рабочий каталог не удалён"
/usr/bin/docker inspect ns-docker-demo >/dev/null 2>&1 && fail "контейнер ns-docker-demo остался"
/usr/sbin/ip netns list | /bin/grep -Eq '^ns-lab-net([[:space:]]|$)' && fail "network namespace остался"
/usr/bin/pgrep -f '/usr/local/lib/ns-lab/ns-(demo|http)' >/dev/null && fail "процессы payload остались"
/usr/sbin/ip link show ns-lab-host >/dev/null 2>&1 && fail "host veth остался"
/usr/bin/jq -e '.clean==true and (.removed|type)=="array" and (.removed|length)>=4' "$f" >/dev/null || fail "cleanup evidence неполон"
pass "все namespace-эксперименты очищены"
