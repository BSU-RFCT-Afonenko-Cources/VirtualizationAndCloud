#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
FILE="$EVIDENCE/hibernation.json"; need_file "$FILE"; need_file "$EVIDENCE/hibernate-http-after.json"
/usr/bin/python3 - "$FILE" <<'PY'
import json,sys
x=json.load(open(sys.argv[1])); assert x['mode'] in ('full','fallback') and x['http_ok'] is True
assert x['counter_after']>x['counter_before']
if x['mode']=='full':
 assert x['restored'] is True and x['session_after']==x['session_before'] and x['starts_after']==x['starts_before']
 assert x['container_id_after']!=x['container_id_before'] and x['artifact_files']>0
else:
 assert x['restored'] is False and x['process_image_created'] is False and x['workflow']=='http-pause-unpause-only'
PY
container_running cr-hibernate || fail "HTTP workload is not running"
pass "hibernation workflow matches the supported environment mode"
