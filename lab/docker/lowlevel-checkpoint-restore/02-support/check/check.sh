#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
need_file "$EVIDENCE/support.json"; need_file "$MODE_FILE"; need_file "$EVIDENCE/diagnostics/criu-check.txt"
/usr/bin/python3 - "$EVIDENCE/support.json" "$MODE_FILE" <<'PY'
import json,sys
x=json.load(open(sys.argv[1])); mode=open(sys.argv[2]).read().strip()
assert mode in ('full','fallback') and x['mode']==mode
for k in ('docker_available','checkpoint_cli','criu_available','criu_check_ok'): assert isinstance(x[k],bool)
assert x['cgroup_version'] in (1,2)
assert isinstance(x['reasons'],list)
if mode=='full': assert all(x[k] for k in ('docker_available','checkpoint_cli','criu_available','criu_check_ok'))
else: assert x['reasons'], 'fallback requires reasons'
PY
pass "support diagnostics selected $(/bin/cat "$MODE_FILE") mode"
