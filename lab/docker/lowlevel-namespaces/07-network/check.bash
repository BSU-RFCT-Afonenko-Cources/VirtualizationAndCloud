#!/bin/bash
source /usr/local/lib/ns-lab/check-common.bash
require_feature network
f=/home/ubuntu/ns-lab/evidence/07-network.json; require_json "$f"
/usr/sbin/ip netns list | /bin/grep -Eq '^ns-lab-net([[:space:]]|$)' || fail "network namespace ns-lab-net отсутствует"
/usr/sbin/ip netns exec ns-lab-net /usr/bin/curl -fsS http://10.203.0.2:8080/health | /usr/bin/jq -e '.service=="ns-http"' >/dev/null || fail "HTTP endpoint недоступен внутри namespace"
/usr/bin/jq -e '.namespace=="ns-lab-net" and (.interfaces|length)>=2 and (.routes|type)=="array" and (.http_response.service=="ns-http")' "$f" >/dev/null || fail "network evidence неполон"
pass "network namespace и HTTP workload работают"
