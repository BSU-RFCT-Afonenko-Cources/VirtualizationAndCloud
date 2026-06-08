#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
FILE="$EVIDENCE/cleanup.json"; need_file "$FILE"
if docker_ok && /usr/bin/docker ps -a --format '{{.Names}}' | /bin/grep -q '^cr-'; then fail "cr-* containers remain"; fi
test ! -e /sys/fs/cgroup/cr-demo-counter || fail "lab cgroup remains"
test ! -e "$CHECKPOINTS" || fail "checkpoint directory remains"
test ! -e "$STATE" || fail "temporary state directory remains"
if /usr/bin/pgrep -x cr-demo-counter >/dev/null 2>&1; then fail "counter process remains"; fi
/usr/bin/python3 - "$FILE" <<'PY'
import json,sys
x=json.load(open(sys.argv[1]));
for k in ('containers_absent','counter_processes_absent','cgroup_absent','checkpoint_directories_absent','state_directories_absent'): assert x[k] is True
assert set(x['checked_categories'])=={'containers','processes','cgroup','checkpoint-artifacts','temporary-state'}
PY
pass "containers, processes, cgroup, checkpoints and temporary state are absent"
