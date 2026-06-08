#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
FILE="$EVIDENCE/terms.json"
need_file "$FILE"
/usr/bin/python3 - "$FILE" <<'PY'
import json,sys
x=json.load(open(sys.argv[1],encoding='utf-8'))
keys={'freeze','checkpoint','restore','filesystem_snapshot','backup'}
assert set(x)==keys, 'unexpected term keys'
for name in keys:
    assert set(x[name])=={'keeps_process_memory','creates_process_image_files','keeps_filesystem_data','result'}
    assert all(isinstance(x[name][k],bool) for k in ('keeps_process_memory','creates_process_image_files','keeps_filesystem_data'))
    assert isinstance(x[name]['result'],str) and x[name]['result']
assert x['freeze']['keeps_process_memory'] and not x['freeze']['creates_process_image_files']
assert x['checkpoint']['keeps_process_memory'] and x['checkpoint']['creates_process_image_files']
assert x['restore']['keeps_process_memory'] and x['restore']['result']=='continued-process'
assert x['filesystem_snapshot']['keeps_filesystem_data'] and not x['filesystem_snapshot']['keeps_process_memory']
assert x['backup']['keeps_filesystem_data'] and not x['backup']['keeps_process_memory']
PY
pass "terms evidence distinguishes runtime and filesystem states"
