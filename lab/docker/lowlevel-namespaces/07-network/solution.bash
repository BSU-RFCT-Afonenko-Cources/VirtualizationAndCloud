#!/bin/bash
set -euo pipefail
f=/home/ubuntu/ns-lab/evidence/07-network.json; pf=/home/ubuntu/ns-lab/state/07-network.pid
/usr/sbin/ip netns del ns-lab-net 2>/dev/null || true; /usr/sbin/ip link del ns-lab-host 2>/dev/null || true
/usr/sbin/ip netns add ns-lab-net; /usr/sbin/ip link add ns-lab-host type veth peer name ns-lab-guest; /usr/sbin/ip link set ns-lab-guest netns ns-lab-net
/usr/sbin/ip addr add 10.203.0.1/24 dev ns-lab-host; /usr/sbin/ip link set ns-lab-host up
/usr/sbin/ip netns exec ns-lab-net /usr/sbin/ip link set lo up; /usr/sbin/ip netns exec ns-lab-net /usr/sbin/ip addr add 10.203.0.2/24 dev ns-lab-guest; /usr/sbin/ip netns exec ns-lab-net /usr/sbin/ip link set ns-lab-guest up
/usr/sbin/ip netns exec ns-lab-net /usr/local/lib/ns-lab/ns-http --bind 10.203.0.2 --port 8080 & p=$!; /usr/bin/printf '%s\n' "$p" > "$pf"; /usr/bin/sleep 1
interfaces=$(/usr/sbin/ip netns exec ns-lab-net /usr/sbin/ip -j addr); routes=$(/usr/sbin/ip netns exec ns-lab-net /usr/sbin/ip -j route); response=$(/usr/sbin/ip netns exec ns-lab-net /usr/bin/curl -fsS http://10.203.0.2:8080/health)
/usr/bin/jq -n --argjson pid "$p" --argjson interfaces "$interfaces" --argjson routes "$routes" --argjson response "$response" '{namespace:"ns-lab-net",pid:$pid,interfaces:$interfaces,routes:$routes,http_url:"http://10.203.0.2:8080/health",http_response:$response}' > "$f"; /usr/bin/chown ubuntu:ubuntu "$f" "$pf"
