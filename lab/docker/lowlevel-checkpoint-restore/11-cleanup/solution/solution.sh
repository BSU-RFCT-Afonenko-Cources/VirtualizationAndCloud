#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
PIDFILE="$LAB/run/host.pid"
if test -f /sys/fs/cgroup/cr-demo-counter/cgroup.freeze; then printf '0\n' >/sys/fs/cgroup/cr-demo-counter/cgroup.freeze || true; fi
if test -f "$PIDFILE"; then pid=$(/bin/cat "$PIDFILE"); /bin/kill "$pid" 2>/dev/null || true; for _ in $(/usr/bin/seq 1 20); do /bin/kill -0 "$pid" 2>/dev/null || break; /bin/sleep 0.1; done; /bin/kill -9 "$pid" 2>/dev/null || true; fi
if docker_ok; then
  mapfile -t containers < <(/usr/bin/docker ps -a --format '{{.Names}}' | /bin/grep '^cr-' || true)
  if test "${#containers[@]}" -gt 0; then /usr/bin/docker rm -f "${containers[@]}" >/dev/null; fi
  /usr/bin/docker image rm "$IMAGE" >/dev/null 2>&1 || true
fi
/bin/rmdir /sys/fs/cgroup/cr-demo-counter 2>/dev/null || true
/bin/rm -rf "$CHECKPOINTS" "$STATE" "$LAB/build" "$LAB/run" "$LAB/bin" "$LAB/src"
/usr/bin/python3 - <<'PY'
import json,os,subprocess
names=[]
try:
 names=subprocess.check_output(['/usr/bin/docker','ps','-a','--format','{{.Names}}'],text=True,stderr=subprocess.DEVNULL).splitlines()
except Exception: pass
alive=[]
for p in os.listdir('/proc'):
 if p.isdigit():
  try:
   if open(f'/proc/{p}/comm').read().strip()=='cr-demo-counter': alive.append(int(p))
  except OSError: pass
x={'containers_absent':not any(n.startswith('cr-') for n in names),'counter_processes_absent':not alive,'cgroup_absent':not os.path.exists('/sys/fs/cgroup/cr-demo-counter'),'checkpoint_directories_absent':not os.path.exists('/home/ubuntu/cr-lab/checkpoints'),'state_directories_absent':not os.path.exists('/home/ubuntu/cr-lab/state'),'checked_categories':['containers','processes','cgroup','checkpoint-artifacts','temporary-state']}
json.dump(x,open('/home/ubuntu/cr-lab/evidence/cleanup.json','w'),indent=2)
PY
lab_owner
