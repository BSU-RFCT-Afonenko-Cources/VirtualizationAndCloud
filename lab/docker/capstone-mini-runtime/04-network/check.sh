#!/bin/bash
set -euo pipefail
source /workspace/VirtualizationAndCloud/lab/docker/capstone-mini-runtime/lib/check-common.sh
require_live_pid
pid=$(api_pid)
ip -j address show dev mrt-host | python3 -c 'import json,sys; d=json.load(sys.stdin)[0]; assert any(x.get("local")=="10.200.0.1" and x.get("prefixlen")==30 for x in d["addr_info"])' || fail 'host veth address is incorrect'
nsenter -t "$pid" -n ip -j address show dev mrt-runtime | python3 -c 'import json,sys; d=json.load(sys.stdin)[0]; assert any(x.get("local")=="10.200.0.2" and x.get("prefixlen")==30 for x in d["addr_info"])' || fail 'runtime veth address is incorrect'
nsenter -t "$pid" -n ip link show lo | grep -q 'state UNKNOWN\|UP' || fail 'runtime loopback is down'
response=$(fetch_api)
[ "$(printf '%s' "$response" | python3 -c 'import json,sys; print(json.load(sys.stdin)["service"])')" = mini-runtime-api ] || fail 'HTTP endpoint returned wrong service'
require_file "$EVIDENCE/network.json"
[ "$(json_value "$EVIDENCE/network.json" endpoint)" = "$ENDPOINT" ] || fail 'network evidence endpoint is stale'
pass 'API is reachable through the explicit veth boundary'
