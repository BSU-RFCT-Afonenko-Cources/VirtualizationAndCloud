#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
docker_ok || fail "Docker daemon is required for pause exercise"
BIN="$LAB/bin/cr-demo-counter"; BUILD="$LAB/build"; DSTATE="$STATE/docker"
test -x "$BIN" || fail "counter binary is absent"
test -f "$LAB/bin/.static" || fail "static counter binary is required for scratch image"
/usr/bin/install -d -o ubuntu -g ubuntu "$BUILD" "$DSTATE"
/usr/bin/install -m 0755 "$BIN" "$BUILD/cr-demo-counter"
/usr/bin/install -m 0644 "$LAB/src/Dockerfile" "$BUILD/Dockerfile"
/usr/bin/docker build -t "$IMAGE" "$BUILD" >"$EVIDENCE/docker-build.log" 2>&1
/usr/bin/docker rm -f cr-docker-counter >/dev/null 2>&1 || true
/usr/bin/docker run -d --name cr-docker-counter --security-opt seccomp=unconfined -p 127.0.0.1:18082:18080 -v "$DSTATE:/state" "$IMAGE" >"$EVIDENCE/docker-container-id.txt"
for _ in $(/usr/bin/seq 1 30); do test -s "$DSTATE/state.json" && break; /bin/sleep 0.2; done
starts=$(json_get "$DSTATE/state.json" starts); session=$(json_get "$DSTATE/state.json" session); pid=$(/usr/bin/docker inspect -f '{{.State.Pid}}' cr-docker-counter)
/usr/bin/docker pause cr-docker-counter >/dev/null
paused=$(/usr/bin/docker inspect -f '{{.State.Paused}}' cr-docker-counter); before=$(state_counter "$DSTATE/state.json"); /bin/sleep 2; during=$(state_counter "$DSTATE/state.json")
/usr/bin/docker unpause cr-docker-counter >/dev/null
for _ in $(/usr/bin/seq 1 30); do after=$(state_counter "$DSTATE/state.json"); test "$after" -gt "$during" && break; /bin/sleep 0.1; done
unpaused=$(/usr/bin/docker inspect -f '{{.State.Paused}}' cr-docker-counter)
/usr/bin/python3 - "$pid" "$paused" "$unpaused" "$before" "$during" "$after" "$starts" "$session" <<'PY'
import json,sys
x={'container':'cr-docker-counter','container_id':open('/home/ubuntu/cr-lab/evidence/docker-container-id.txt').read().strip(),'pid':int(sys.argv[1]),'paused':sys.argv[2]=='true','paused_after_unpause':sys.argv[3]=='true','counter_before':int(sys.argv[4]),'counter_during':int(sys.argv[5]),'counter_after':int(sys.argv[6]),'starts':int(sys.argv[7]),'session':sys.argv[8]}
json.dump(x,open('/home/ubuntu/cr-lab/evidence/docker-pause.json','w'),indent=2)
PY
lab_owner
