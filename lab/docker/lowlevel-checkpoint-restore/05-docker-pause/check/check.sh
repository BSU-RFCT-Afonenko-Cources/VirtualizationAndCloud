#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
FILE="$EVIDENCE/docker-pause.json"; need_file "$FILE"
container_running cr-docker-counter || fail "cr-docker-counter is not running"
test "$(/usr/bin/docker inspect -f '{{.State.Paused}}' cr-docker-counter)" = false || fail "container remains paused"
/usr/bin/python3 - "$FILE" <<'PY'
import json,sys
x=json.load(open(sys.argv[1])); assert x['container']=='cr-docker-counter' and x['container_id']
assert x['paused'] is True and x['paused_after_unpause'] is False
assert x['counter_during']==x['counter_before'] and x['counter_after']>x['counter_during']
assert x['starts']>=1 and x['session']
PY
pass "Docker pause/unpause preserved and resumed progress"
