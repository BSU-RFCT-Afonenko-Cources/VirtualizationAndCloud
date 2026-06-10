#!/usr/bin/env bash
set -euo pipefail
STEP=${1:?step number required}
LAB=/home/ubuntu/lowlevel-security-primitives
E=$LAB/evidence
P=$LAB/profiles/seccomp-deny-uname.json
mkdir -p "$E" "$LAB/runtime"
inspect_status() {
  local name=$1 out=$2 pid
  docker inspect "$name" > "$E/$out-inspect.json"
  pid=$(docker inspect -f '{{.State.Pid}}' "$name")
  cat "/proc/$pid/status" > "$E/$out-status.txt"
  readlink "/proc/$pid/ns/user" > "$E/$out-userns.txt"
  cat "/proc/$pid/uid_map" > "$E/$out-uid-map.txt"
  cat "/proc/$pid/gid_map" > "$E/$out-gid-map.txt"
  cat "/proc/$pid/mountinfo" > "$E/$out-mountinfo.txt"
}
case "$STEP" in
01)
  docker rm -f lsp-baseline >/dev/null 2>&1 || true
  docker run -d --name lsp-baseline sec-demo:lab >/dev/null
  inspect_status lsp-baseline baseline
  docker exec lsp-baseline python3 /home/ubuntu/lowlevel-security-primitives/sec-demo/sec_demo.py diag > "$E/baseline-diag.json"
  docker exec lsp-baseline find /dev -maxdepth 2 -printf '%y %p %m\n' > "$E/baseline-devices.txt"
  ;;
02)
  docker rm -f lsp-cap-default lsp-cap-minimal >/dev/null 2>&1 || true
  docker run -d --name lsp-cap-default sec-demo:lab >/dev/null
  docker run -d --name lsp-cap-minimal --cap-drop ALL --cap-add NET_RAW sec-demo:lab >/dev/null
  inspect_status lsp-cap-default cap-default
  inspect_status lsp-cap-minimal cap-minimal
  ;;
03)
  docker rm -f lsp-sysadmin >/dev/null 2>&1 || true
  docker run --rm --cap-drop ALL sec-demo:lab python3 /home/ubuntu/lowlevel-security-primitives/sec-demo/sec_demo.py diag > "$E/sysadmin-denied.json"
  docker run --name lsp-sysadmin --cap-drop ALL --cap-add SYS_ADMIN --security-opt seccomp=unconfined --security-opt apparmor=unconfined sec-demo:lab python3 /home/ubuntu/lowlevel-security-primitives/sec-demo/sec_demo.py diag > "$E/sysadmin-allowed.json" || true
  docker inspect lsp-sysadmin > "$E/sysadmin-inspect.json"
  docker rm -f lsp-sysadmin >/dev/null
  ;;
04)
  docker rm -f lsp-userns >/dev/null 2>&1 || true
  if docker run -d --name lsp-userns sec-demo:lab >/dev/null 2>"$E/userns-error.txt"; then
    inspect_status lsp-userns userns
    python3 - "$E/userns-classification.json" "$E/userns-uid-map.txt" <<'PY'
import json,sys
rows=[list(map(int,x.split())) for x in open(sys.argv[2]) if x.strip()]
kind='remapped' if rows and (rows[0][0] != rows[0][1] or rows[0][1] != 0) else 'identity-map'
json.dump({'supported': True, 'classification': kind, 'uid_map': rows},open(sys.argv[1],'w'),indent=2)
PY
  else
    python3 - "$E/userns-classification.json" "$E/userns-error.txt" <<'PY'
import json,sys
json.dump({'supported':False,'classification':'unavailable','diagnostic':open(sys.argv[2]).read().strip()},open(sys.argv[1],'w'),indent=2)
PY
  fi
  ;;
05)
  docker info --format '{{json .}}' > "$E/docker-info.json"
  docker info > "$E/docker-info.txt"
  python3 - "$E/docker-mode.json" "$E/docker-info.json" <<'PY'
import json,sys
x=json.load(open(sys.argv[2])); opts=x.get('SecurityOptions') or []
rootless=any('rootless' in str(v).lower() for v in opts)
json.dump({'mode':'rootless' if rootless else 'rootful','rootless':rootless,'security_options':opts},open(sys.argv[1],'w'),indent=2)
PY
  ;;
06)
  docker rm -f lsp-seccomp-default lsp-seccomp-custom >/dev/null 2>&1 || true
  docker run -d --name lsp-seccomp-default sec-demo:lab >/dev/null
  docker run -d --name lsp-seccomp-custom --security-opt "seccomp=$P" sec-demo:lab >/dev/null
  inspect_status lsp-seccomp-default seccomp-default
  inspect_status lsp-seccomp-custom seccomp-custom
  docker exec lsp-seccomp-default python3 /home/ubuntu/lowlevel-security-primitives/sec-demo/sec_demo.py diag > "$E/seccomp-default-diag.json"
  docker exec lsp-seccomp-custom python3 /home/ubuntu/lowlevel-security-primitives/sec-demo/sec_demo.py diag > "$E/seccomp-custom-diag.json"
  ;;
07)
  docker rm -f lsp-nnp-off lsp-nnp-on >/dev/null 2>&1 || true
  docker run -d --name lsp-nnp-off --user 10001:10001 sec-demo:lab >/dev/null
  docker run -d --name lsp-nnp-on --user 10001:10001 --security-opt no-new-privileges sec-demo:lab >/dev/null
  inspect_status lsp-nnp-off nnp-off
  inspect_status lsp-nnp-on nnp-on
  docker exec lsp-nnp-off /usr/local/bin/setuid-probe > "$E/nnp-off-probe.txt" || true
  docker exec lsp-nnp-on /usr/local/bin/setuid-probe > "$E/nnp-on-probe.txt" || true
  ;;
08)
  docker rm -f lsp-readonly >/dev/null 2>&1 || true
  docker run -d --name lsp-readonly --read-only --tmpfs /home/ubuntu/lowlevel-security-primitives/tmp:rw,noexec,nosuid,size=16m --tmpfs /home/ubuntu/lowlevel-security-primitives/run:rw,noexec,nosuid,size=16m sec-demo:lab >/dev/null
  inspect_status lsp-readonly readonly
  docker exec lsp-readonly python3 /home/ubuntu/lowlevel-security-primitives/sec-demo/sec_demo.py diag > "$E/readonly-diag.json"
  ;;
09)
  docker rm -f lsp-privileged >/dev/null 2>&1 || true
  docker run --name lsp-privileged --privileged sec-demo:lab python3 /home/ubuntu/lowlevel-security-primitives/sec-demo/sec_demo.py diag > "$E/privileged-diag.json" || true
  docker inspect lsp-privileged > "$E/privileged-inspect.json"
  docker rm -f lsp-privileged >/dev/null
  docker run --rm sec-demo:lab python3 /home/ubuntu/lowlevel-security-primitives/sec-demo/sec_demo.py diag > "$E/ordinary-diag.json"
  ;;
10)
  docker rm -f lsp-hardened >/dev/null 2>&1 || true
  docker run -d --name lsp-hardened -p 127.0.0.1::8080 --user 10001:10001 --cap-drop ALL --security-opt no-new-privileges --read-only --tmpfs /home/ubuntu/lowlevel-security-primitives/tmp:rw,noexec,nosuid,size=16m --tmpfs /home/ubuntu/lowlevel-security-primitives/run:rw,noexec,nosuid,size=16m --health-cmd 'python3 -c "import urllib.request; urllib.request.urlopen(\"http://127.0.0.1:8080/health\")"' --health-interval 2s --health-timeout 2s --health-retries 10 sec-demo:lab >/dev/null
  inspect_status lsp-hardened hardened
  docker inspect lsp-hardened > "$E/hardened-final-inspect.json"
  port=$(docker port lsp-hardened 8080/tcp | awk -F: 'END{print $NF}')
  python3 - "$port" "$E/hardened-health.txt" <<'PY'
import sys,time,urllib.request
url='http://127.0.0.1:'+sys.argv[1]+'/health'
for _ in range(20):
 try:
  data=urllib.request.urlopen(url,timeout=2).read().decode(); open(sys.argv[2],'w').write(data); break
 except Exception: time.sleep(1)
else: raise SystemExit('health endpoint unavailable')
PY
  ;;
*) exit 2;;
esac
chown -R ubuntu:ubuntu "$LAB"
