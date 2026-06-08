#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
FILE="$EVIDENCE/freeze.json"; need_file "$FILE"
/usr/bin/python3 - "$FILE" <<'PY'
import json,sys
x=json.load(open(sys.argv[1])); assert x['cgroup']=='/sys/fs/cgroup/cr-demo-counter'
assert x['frozen_state']==1 and x['counter_during']==x['counter_before']
assert x['counter_after']>x['counter_during'] and x['checkpoint_files_created']==0
PY
pid=$(json_get "$FILE" pid); /bin/kill -0 "$pid" 2>/dev/null || fail "thawed process is not alive"
test "$(/bin/cat /sys/fs/cgroup/cr-demo-counter/cgroup.freeze)" = 0 || fail "cgroup remains frozen"
pass "cgroup freezer stopped and resumed the same process"
