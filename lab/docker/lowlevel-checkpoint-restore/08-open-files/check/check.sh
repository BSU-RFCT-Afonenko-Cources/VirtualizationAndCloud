#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
FILE="$EVIDENCE/open-files.json"; need_file "$FILE"
/usr/bin/python3 - "$FILE" <<'PY'
import json,sys,os
x=json.load(open(sys.argv[1])); assert x['mode'] in ('full','fallback')
assert x['inode']>0 and x['size_after']>x['size_before'] and x['old_data_preserved'] is True
assert x['first_record_sha256'] and x['session'] and x['last_record']
assert os.path.islink(x['fd_path'])
assert x['proves_restore'] is (x['mode']=='full')
PY
pass "open journal descriptor and growing volume data verified"
