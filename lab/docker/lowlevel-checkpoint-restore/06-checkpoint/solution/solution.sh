#!/bin/bash
set -uo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
C=cr-docker-counter; CP=cr-checkpoint-1; DSTATE="$STATE/docker"
container_exists "$C" || fail "container $C does not exist"
need_file "$DSTATE/state.json"
before=$(state_counter "$DSTATE/state.json"); session=$(json_get "$DSTATE/state.json" session); starts=$(json_get "$DSTATE/state.json" starts)
ERR="$EVIDENCE/checkpoint-create.stderr"; : >"$ERR"
/usr/bin/docker checkpoint rm "$C" "$CP" >/dev/null 2>&1 || true
/usr/bin/docker checkpoint create "$C" "$CP" >"$EVIDENCE/checkpoint-create.stdout" 2>"$ERR"; rc=$?
if test "$rc" -eq 0; then
  printf 'full\n' >"$MODE_FILE"
  /usr/bin/docker checkpoint ls "$C" >"$EVIDENCE/checkpoint-list.txt" 2>&1
  id=$(/usr/bin/docker inspect -f '{{.Id}}' "$C"); root=$(/usr/bin/docker info -f '{{.DockerRootDir}}' 2>/dev/null); dir="$root/containers/$id/checkpoints/$CP"
  artifacts=$(/usr/bin/find "$dir" -type f 2>/dev/null | /usr/bin/wc -l)
  /usr/bin/python3 - "$before" "$session" "$starts" "$dir" "$artifacts" <<'PY'
import json,sys
x={'container':'cr-docker-counter','checkpoint':'cr-checkpoint-1','counter_before':int(sys.argv[1]),'session_before':sys.argv[2],'starts_before':int(sys.argv[3]),'checkpoint_dir':sys.argv[4],'artifact_files':int(sys.argv[5]),'created':True}
json.dump(x,open('/home/ubuntu/cr-lab/evidence/checkpoint.json','w'),indent=2)
PY
  /bin/rm -f "$EVIDENCE/checkpoint-unsupported.json"
else
  printf 'fallback\n' >"$MODE_FILE"
  stderr=$(/bin/cat "$ERR")
  /usr/bin/python3 - "$rc" "$stderr" <<'PY'
import json,sys
x={'operation':'docker checkpoint create cr-docker-counter cr-checkpoint-1','exit_code':int(sys.argv[1]),'stderr':sys.argv[2],'reason':'runtime-checkpoint-attempt-failed'}
json.dump(x,open('/home/ubuntu/cr-lab/evidence/checkpoint-unsupported.json','w'),indent=2)
json.dump({'container':'cr-docker-counter','checkpoint':'cr-checkpoint-1','created':False,'mode':'fallback'},open('/home/ubuntu/cr-lab/evidence/checkpoint.json','w'),indent=2)
PY
  if container_exists "$C" && ! container_running "$C"; then /usr/bin/docker start "$C" >/dev/null 2>&1 || true; fi
fi
lab_owner
exit 0
