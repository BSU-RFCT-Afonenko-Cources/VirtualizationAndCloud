#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
FILE="$EVIDENCE/checkpoint.json"; need_file "$FILE"
if full_mode; then
  /usr/bin/docker checkpoint ls cr-docker-counter | /bin/grep -qx 'cr-checkpoint-1' || fail "named checkpoint is absent"
  /usr/bin/python3 - "$FILE" <<'PY'
import json,sys,os
x=json.load(open(sys.argv[1])); assert x['created'] is True and x['checkpoint']=='cr-checkpoint-1'
assert x['counter_before']>0 and x['session_before'] and x['starts_before']>=1
assert x['artifact_files']>0 and os.path.isdir(x['checkpoint_dir'])
PY
  pass "checkpoint artifacts and named checkpoint exist"
else
  U="$EVIDENCE/checkpoint-unsupported.json"; need_file "$U"
  /usr/bin/python3 - "$U" <<'PY'
import json,sys
x=json.load(open(sys.argv[1])); assert x['operation'].startswith('docker checkpoint create')
assert x['exit_code']!=0 and x['stderr'].strip() and x['reason']
PY
  pass "fallback records a real failed checkpoint attempt"
fi
