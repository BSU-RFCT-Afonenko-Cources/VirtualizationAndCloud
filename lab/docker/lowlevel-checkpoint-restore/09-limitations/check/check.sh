#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
FILE="$EVIDENCE/negative-test.json"; need_file "$FILE"
/usr/bin/python3 - "$FILE" <<'PY'
import json,sys
x=json.load(open(sys.argv[1])); assert x['tested_feature']=='checkpoint-container-with-external-tty'
assert x['container_settings']['tty'] is True and x['main_workload_unchanged'] is True
assert x['outcome'] in ('expected-failure','unexpected-success','setup-failure') and x['reason']
if x['outcome']!='unexpected-success': assert x['exit_code']!=0 and x['stderr'].strip()
else: assert x['exit_code']==0
PY
container_exists cr-docker-counter || fail "negative test removed the main workload"
pass "isolated TTY checkpoint limitation was recorded"
