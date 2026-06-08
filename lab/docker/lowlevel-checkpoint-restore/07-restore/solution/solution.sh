#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
OUT="$EVIDENCE/restore.json"; C=cr-docker-counter; DSTATE="$STATE/docker"
if full_mode; then
  need_file "$EVIDENCE/checkpoint.json"
  before=$(json_get "$EVIDENCE/checkpoint.json" counter_before); session=$(json_get "$EVIDENCE/checkpoint.json" session_before); starts=$(json_get "$EVIDENCE/checkpoint.json" starts_before)
  /usr/bin/docker start --checkpoint cr-checkpoint-1 "$C" >"$EVIDENCE/restore.stdout" 2>"$EVIDENCE/restore.stderr"
  for _ in $(/usr/bin/seq 1 50); do test -s "$DSTATE/state.json" && after=$(state_counter "$DSTATE/state.json") && test "$after" -gt "$before" && break; /bin/sleep 0.2; done
  after=$(state_counter "$DSTATE/state.json"); session_after=$(json_get "$DSTATE/state.json" session); starts_after=$(json_get "$DSTATE/state.json" starts)
  /usr/bin/docker inspect "$C" >"$EVIDENCE/restore-inspect.json"
  /usr/bin/docker checkpoint ls "$C" >"$EVIDENCE/restore-checkpoint-list.txt"
  /usr/bin/python3 - "$before" "$after" "$session" "$session_after" "$starts" "$starts_after" <<'PY'
import json,sys
x={'mode':'full','restored':True,'counter_before':int(sys.argv[1]),'counter_after':int(sys.argv[2]),'session_before':sys.argv[3],'session_after':sys.argv[4],'starts_before':int(sys.argv[5]),'starts_after':int(sys.argv[6])}
json.dump(x,open('/home/ubuntu/cr-lab/evidence/restore.json','w'),indent=2)
PY
else
  need_file "$EVIDENCE/checkpoint-unsupported.json"
  /usr/bin/python3 - <<'PY'
import json
u=json.load(open('/home/ubuntu/cr-lab/evidence/checkpoint-unsupported.json'))
x={'mode':'fallback','restored':False,'restart_claimed_as_restore':False,'blocked_by':u['reason'],'checkpoint_exit_code':u['exit_code']}
json.dump(x,open('/home/ubuntu/cr-lab/evidence/restore.json','w'),indent=2)
PY
fi
lab_owner
