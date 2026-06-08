#!/bin/bash
set -uo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
C=cr-negative-tty; CP=cr-negative-checkpoint; ERR="$EVIDENCE/negative-test.stderr"
/usr/bin/docker rm -f "$C" >/dev/null 2>&1 || true
/usr/bin/docker run -d -t --name "$C" --security-opt seccomp=unconfined "$IMAGE" >"$EVIDENCE/negative-container-id.txt" 2>"$EVIDENCE/negative-run.stderr"; run_rc=$?
if test "$run_rc" -eq 0; then
  tty=$(/usr/bin/docker inspect -f '{{.Config.Tty}}' "$C")
  /usr/bin/docker checkpoint create "$C" "$CP" >"$EVIDENCE/negative-test.stdout" 2>"$ERR"; rc=$?
  if test "$rc" -eq 0; then outcome=unexpected-success; reason="runtime-supported-tty-checkpoint"; else outcome=expected-failure; reason="tty-or-runtime-resource-rejected"; fi
else
  tty=true; rc=$run_rc; outcome=setup-failure; reason="negative-container-could-not-start"; /bin/cp "$EVIDENCE/negative-run.stderr" "$ERR"
fi
stderr=$(/bin/cat "$ERR" 2>/dev/null)
/usr/bin/python3 - "$tty" "$outcome" "$rc" "$stderr" "$reason" "$(/bin/cat "$MODE_FILE")" <<'PY'
import json,sys
x={'tested_feature':'checkpoint-container-with-external-tty','container':'cr-negative-tty','container_settings':{'tty':sys.argv[1]=='true'},'outcome':sys.argv[2],'exit_code':int(sys.argv[3]),'stderr':sys.argv[4],'reason':sys.argv[5],'main_mode':sys.argv[6],'main_workload_unchanged':True}
json.dump(x,open('/home/ubuntu/cr-lab/evidence/negative-test.json','w'),indent=2)
PY
if container_exists "$C" && ! container_running "$C"; then /usr/bin/docker start "$C" >/dev/null 2>&1 || true; fi
lab_owner
exit 0
