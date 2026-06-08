#!/bin/bash
set -uo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
C=cr-hibernate; CP=hibernate-1; HSTATE="$STATE/hibernate"; HDIR="$CHECKPOINTS/hibernate"; OUT="$EVIDENCE/hibernation.json"
/usr/bin/docker rm -f "$C" >/dev/null 2>&1 || true
/bin/rm -rf "$HSTATE" "$HDIR"; /usr/bin/install -d -o ubuntu -g ubuntu "$HSTATE" "$HDIR"
/usr/bin/docker run -d --name "$C" --security-opt seccomp=unconfined -p 127.0.0.1:18083:18080 -v "$HSTATE:/state" "$IMAGE" >"$EVIDENCE/hibernate-container-id-before.txt" 2>"$EVIDENCE/hibernate-run.stderr" || fail "cannot start hibernation workload"
for _ in $(/usr/bin/seq 1 40); do test -s "$HSTATE/state.json" && break; /bin/sleep 0.2; done
/usr/bin/python3 - <<'PY' >"$EVIDENCE/hibernate-http-before.json"
import urllib.request
print(urllib.request.urlopen('http://127.0.0.1:18083/',timeout=3).read().decode(),end='')
PY
before=$(state_counter "$EVIDENCE/hibernate-http-before.json"); session=$(json_get "$EVIDENCE/hibernate-http-before.json" session); starts=$(json_get "$EVIDENCE/hibernate-http-before.json" starts)

if full_mode; then
  /usr/bin/docker checkpoint create --checkpoint-dir "$HDIR" "$C" "$CP" >"$EVIDENCE/hibernate-checkpoint.stdout" 2>"$EVIDENCE/hibernate-checkpoint.stderr"; rc=$?
  if test "$rc" -eq 0; then
    old_id=$(/bin/cat "$EVIDENCE/hibernate-container-id-before.txt")
    /usr/bin/docker rm "$C" >/dev/null 2>&1
    /usr/bin/docker create --name "$C" --security-opt seccomp=unconfined -p 127.0.0.1:18083:18080 -v "$HSTATE:/state" "$IMAGE" >"$EVIDENCE/hibernate-container-id-after.txt"
    /usr/bin/docker start --checkpoint "$CP" --checkpoint-dir "$HDIR" "$C" >"$EVIDENCE/hibernate-restore.stdout" 2>"$EVIDENCE/hibernate-restore.stderr"; restore_rc=$?
    if test "$restore_rc" -eq 0; then
      for _ in $(/usr/bin/seq 1 50); do
        if /usr/bin/python3 - <<'PY' >"$EVIDENCE/hibernate-http-after.json" 2>/dev/null
import urllib.request
print(urllib.request.urlopen('http://127.0.0.1:18083/',timeout=1).read().decode(),end='')
PY
        then candidate=$(state_counter "$EVIDENCE/hibernate-http-after.json"); test "$candidate" -gt "$before" && break; fi
        /bin/sleep 0.2
      done
      after=$(state_counter "$EVIDENCE/hibernate-http-after.json"); session_after=$(json_get "$EVIDENCE/hibernate-http-after.json" session); starts_after=$(json_get "$EVIDENCE/hibernate-http-after.json" starts); new_id=$(/bin/cat "$EVIDENCE/hibernate-container-id-after.txt"); artifacts=$(/usr/bin/find "$HDIR" -type f | /usr/bin/wc -l)
      /usr/bin/python3 - "$before" "$after" "$session" "$session_after" "$starts" "$starts_after" "$old_id" "$new_id" "$artifacts" <<'PY'
import json,sys
x={'mode':'full','workflow':'external-checkpoint-remove-create-restore','restored':True,'counter_before':int(sys.argv[1]),'counter_after':int(sys.argv[2]),'session_before':sys.argv[3],'session_after':sys.argv[4],'starts_before':int(sys.argv[5]),'starts_after':int(sys.argv[6]),'container_id_before':sys.argv[7],'container_id_after':sys.argv[8],'artifact_files':int(sys.argv[9]),'http_ok':True}
json.dump(x,open('/home/ubuntu/cr-lab/evidence/hibernation.json','w'),indent=2)
PY
      lab_owner; exit 0
    fi
  fi
  printf 'fallback\n' >"$MODE_FILE"
  /usr/bin/docker rm -f "$C" >/dev/null 2>&1 || true
  /usr/bin/docker run -d --name "$C" --security-opt seccomp=unconfined -p 127.0.0.1:18083:18080 -v "$HSTATE:/state" "$IMAGE" >/dev/null
fi
# Honest fallback: exercise a temporary hibernation-like pause, without claiming process-image persistence.
/usr/bin/docker pause "$C" >/dev/null; /bin/sleep 1; /usr/bin/docker unpause "$C" >/dev/null
for _ in $(/usr/bin/seq 1 40); do
  if /usr/bin/python3 - <<'PY' >"$EVIDENCE/hibernate-http-after.json" 2>/dev/null
import urllib.request
print(urllib.request.urlopen('http://127.0.0.1:18083/',timeout=1).read().decode(),end='')
PY
  then candidate=$(state_counter "$EVIDENCE/hibernate-http-after.json"); test "$candidate" -gt "$before" && break; fi
  /bin/sleep 0.2
done
after=$(state_counter "$EVIDENCE/hibernate-http-after.json")
/usr/bin/python3 - "$before" "$after" <<'PY'
import json,sys
x={'mode':'fallback','workflow':'http-pause-unpause-only','restored':False,'process_image_created':False,'counter_before':int(sys.argv[1]),'counter_after':int(sys.argv[2]),'http_ok':True,'limitation':'checkpoint-or-external-restore-unavailable'}
json.dump(x,open('/home/ubuntu/cr-lab/evidence/hibernation.json','w'),indent=2)
PY
lab_owner
