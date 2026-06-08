#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
FILE="$EVIDENCE/restore.json"; need_file "$FILE"
if full_mode; then
  container_running cr-docker-counter || fail "restored container is not running"
  need_file "$EVIDENCE/restore-inspect.json"; need_file "$EVIDENCE/restore-checkpoint-list.txt"
  /usr/bin/python3 - "$FILE" <<'PY'
import json,sys
x=json.load(open(sys.argv[1])); assert x['mode']=='full' and x['restored'] is True
assert x['counter_after']>x['counter_before']
assert x['session_after']==x['session_before'] and x['starts_after']==x['starts_before']
PY
  pass "restored process continued without entrypoint restart"
else
  /usr/bin/python3 - "$FILE" <<'PY'
import json,sys
x=json.load(open(sys.argv[1])); assert x['mode']=='fallback' and x['restored'] is False
assert x['restart_claimed_as_restore'] is False and x['blocked_by'] and x['checkpoint_exit_code']!=0
PY
  pass "fallback does not represent restart as restore"
fi
