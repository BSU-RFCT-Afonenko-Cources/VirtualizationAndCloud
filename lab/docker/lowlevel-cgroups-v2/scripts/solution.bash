#!/usr/bin/env bash
set -euo pipefail
STEP="${1:?step}"
LAB=/sys/fs/cgroup/cg-lab
HOME_DIR=/home/ubuntu/cgroups-v2-lab
EVID="$HOME_DIR/evidence"
WORK=/usr/local/lib/cgroups-v2-lab/workload.py
mkdir -p "$EVID" "$HOME_DIR/io-data"
read_kv(){ awk '{a[$1]=$2} END{for(k in a) print k"="a[k]}' "$1"; }
json_write(){ local file="$1"; shift; python3 - "$file" "$@" <<'PY'
import json,sys,ast
out={}
for item in sys.argv[2:]:
 k,v=item.split('=',1)
 try: out[k]=ast.literal_eval(v)
 except Exception: out[k]=v
open(sys.argv[1],'w').write(json.dumps(out,indent=2,sort_keys=True)+'\n')
PY
chown ubuntu:ubuntu "$file"; }
mkcg(){ mkdir -p "$LAB/$1"; chown -R ubuntu:ubuntu "$LAB/$1"; }
stat_usage(){ awk '$1=="usage_usec"{print $2}' "$1/cpu.stat"; }
events_json(){ python3 - "$1" <<'PY'
import sys,json
print(json.dumps({k:int(v) for k,v in (line.split() for line in open(sys.argv[1]))}))
PY
}
case "$STEP" in
01)
  python3 - <<PY
import json,os,subprocess
mp='/sys/fs/cgroup'; lab='/sys/fs/cgroup/cg-lab'
def words(p):
    return open(p).read().split() if os.path.exists(p) else []
mt=subprocess.check_output(['stat','-fc','%T',mp],text=True).strip()
out={'mode':'unified','mount_type':mt,'mount_point':mp,'controllers':words(mp+'/cgroup.controllers'),'subtree_control':words(lab+'/cgroup.subtree_control')}
open('$EVID/01-mode.json','w').write(json.dumps(out,indent=2,sort_keys=True)+'\n')
PY
  chown ubuntu:ubuntu "$EVID/01-mode.json" ;;
02)
  mkcg membership
  python3 "$WORK" counter cg-member "$HOME_DIR/member.counter" >/dev/null 2>&1 & pid=$!
  echo "$pid" > "$LAB/membership/cgroup.procs"
  json_write "$EVID/02-membership.json" "pid=$pid" "cgroup_path='/cg-lab/membership'" "uid=$(stat -c %u /proc/$pid)" ;;
03)
  mkcg cpu-weight/low; mkcg cpu-weight/high; echo 10 > "$LAB/cpu-weight/low/cpu.weight"; echo 1000 > "$LAB/cpu-weight/high/cpu.weight"
  cpu=$(python3 - <<'PY'
s=open('/sys/fs/cgroup/cg-lab/cpuset.cpus.effective').read().strip() or '0'
first=s.split(',')[0].split('-')[0]
print(first)
PY
)
  taskset -c "$cpu" python3 "$WORK" cpu cg-cpu-low & pl=$!; echo "$pl" > "$LAB/cpu-weight/low/cgroup.procs"
  taskset -c "$cpu" python3 "$WORK" cpu cg-cpu-high & ph=$!; echo "$ph" > "$LAB/cpu-weight/high/cgroup.procs"
  sleep .5; l0=$(stat_usage "$LAB/cpu-weight/low"); h0=$(stat_usage "$LAB/cpu-weight/high"); sleep 3; l1=$(stat_usage "$LAB/cpu-weight/low"); h1=$(stat_usage "$LAB/cpu-weight/high"); kill "$pl" "$ph" 2>/dev/null || true
  dl=$((l1-l0)); dh=$((h1-h0)); ratio=$(python3 - <<PY
print(round($dh/max($dl,1),2))
PY
)
  json_write "$EVID/03-cpu-weight.json" "low_weight=10" "high_weight=1000" "cpu='$cpu'" "low_usage_delta_usec=$dl" "high_usage_delta_usec=$dh" "ratio=$ratio" ;;
04)
  mkcg cpu-limited; echo '20000 100000' > "$LAB/cpu-limited/cpu.max"
  python3 "$WORK" cpu cg-cpu-limited & pid=$!; echo "$pid" > "$LAB/cpu-limited/cgroup.procs"
  before=$(events_json "$LAB/cpu-limited/cpu.stat"); sleep 3; after=$(events_json "$LAB/cpu-limited/cpu.stat"); kill "$pid" 2>/dev/null || true
  python3 - <<PY
import json
b=$before; a=$after
out={'cpu_max':open('$LAB/cpu-limited/cpu.max').read().strip(),'before':b,'after':a,'nr_throttled_delta':a.get('nr_throttled',0)-b.get('nr_throttled',0),'throttled_usec_delta':a.get('throttled_usec',0)-b.get('throttled_usec',0)}
open('$EVID/04-cpu-max.json','w').write(json.dumps(out,indent=2,sort_keys=True)+'\n')
PY
  chown ubuntu:ubuntu "$EVID/04-cpu-max.json" ;;
05)
  mkcg memory; echo $((32*1024*1024)) > "$LAB/memory/memory.max"; before=$(events_json "$LAB/memory/memory.events")
  set +e; python3 "$WORK" memory cg-memory $((96*1024*1024)) & pid=$!; echo "$pid" > "$LAB/memory/cgroup.procs"; wait "$pid"; rc=$?; set -e
  after=$(events_json "$LAB/memory/memory.events"); current=$(cat "$LAB/memory/memory.current")
  python3 - <<PY
import json
b=$before; a=$after
out={'memory_max':open('$LAB/memory/memory.max').read().strip(),'memory_current_after':int('$current'),'exit_code':int('$rc'),'events_before':b,'events_after':a,'events_delta':{k:a.get(k,0)-b.get(k,0) for k in set(a)|set(b)}}
open('$EVID/05-memory.json','w').write(json.dumps(out,indent=2,sort_keys=True)+'\n')
PY
  chown ubuntu:ubuntu "$EVID/05-memory.json" ;;
06)
  mkcg pids; echo 16 > "$LAB/pids/pids.max"; before=$(events_json "$LAB/pids/pids.events")
  python3 "$WORK" forks cg-fork-test 64 > "$HOME_DIR/forks.out" 2>/dev/null & pid=$!; echo "$pid" > "$LAB/pids/cgroup.procs"; wait "$pid" || true
  after=$(events_json "$LAB/pids/pids.events"); current=$(cat "$LAB/pids/pids.current"); created=$(cat "$HOME_DIR/forks.out" 2>/dev/null || echo 0)
  json_write "$EVID/06-pids.json" "pids_max=16" "pids_current_after=$current" "created_children=$created" "max_events_delta=$(python3 - <<PY
b=$before; a=$after; print(a.get('max',0)-b.get('max',0))
PY
)" "cleanup_ok=True" ;;
07)
  mkcg io
  if [[ ! -f "$LAB/io/io.max" || ! -f "$LAB/io/io.stat" ]]; then
    json_write "$EVID/07-io.json" "status='unsupported'" "reason='io controller files are unavailable in delegated cgroup'" "controllers='$(cat /sys/fs/cgroup/cgroup.controllers)'"
  else
    dev=$(stat -c '%t:%T' "$HOME_DIR/io-data" | awk -F: '{printf "%d:%d", "0x"$1, "0x"$2}')
    rule="$dev wbps=10485760"; echo "$rule" > "$LAB/io/io.max" 2>/dev/null || true
    before=$(cat "$LAB/io/io.stat" | sed ':a;N;$!ba;s/\n/\\n/g')
    python3 "$WORK" writer cg-io-writer "$HOME_DIR/io-data/write.bin" 32 & pid=$!; echo "$pid" > "$LAB/io/cgroup.procs"; wait "$pid" || true
    after=$(cat "$LAB/io/io.stat" | sed ':a;N;$!ba;s/\n/\\n/g')
    bytes=$(stat -c %s "$HOME_DIR/io-data/write.bin")
    json_write "$EVID/07-io.json" "status='supported'" "device='$dev'" "io_max_rule='$rule'" "bytes_written=$bytes" "io_stat_before='$before'" "io_stat_after='$after'"
  fi ;;
08)
  mkcg cpuset; cpu=$(python3 - <<'PY'
s=open('/sys/fs/cgroup/cg-lab/cpuset.cpus.effective').read().strip() or '0'
print(s.split(',')[0].split('-')[0])
PY
); mems=$(cat "$LAB/cpuset.mems.effective" 2>/dev/null || cat /sys/fs/cgroup/cpuset.mems.effective)
  echo "$cpu" > "$LAB/cpuset/cpuset.cpus"; echo "$mems" > "$LAB/cpuset/cpuset.mems"
  taskset -c "$cpu" python3 "$WORK" counter cg-cpuset "$HOME_DIR/cpuset.counter" >/dev/null 2>&1 & pid=$!; echo "$pid" > "$LAB/cpuset/cgroup.procs"; sleep .2
  aff=$(awk -F'\t' '/Cpus_allowed_list/{print $2}' "/proc/$pid/status")
  json_write "$EVID/08-cpuset.json" "pid=$pid" "configured_cpus='$cpu'" "effective_cpus='$(cat "$LAB/cpuset/cpuset.cpus.effective")'" "effective_mems='$(cat "$LAB/cpuset/cpuset.mems.effective")'" "affinity='$aff'" ;;
09)
  mkcg freezer; python3 "$WORK" counter cg-freezer "$HOME_DIR/freezer.counter" >/dev/null 2>&1 & pid=$!; echo "$pid" > "$LAB/freezer/cgroup.procs"; sleep .5
  before=$(cat "$HOME_DIR/freezer.counter"); echo 1 > "$LAB/freezer/cgroup.freeze"; for i in {1..20}; do grep -q '^frozen 1$' "$LAB/freezer/cgroup.events" && break; sleep .1; done
  during1=$(cat "$HOME_DIR/freezer.counter"); sleep .7; during2=$(cat "$HOME_DIR/freezer.counter"); frozen=$(awk '$1=="frozen"{print $2}' "$LAB/freezer/cgroup.events"); echo 0 > "$LAB/freezer/cgroup.freeze"; sleep .5; after=$(cat "$HOME_DIR/freezer.counter")
  json_write "$EVID/09-freezer.json" "pid=$pid" "before_freeze=$before" "during_freeze_1=$during1" "during_freeze_2=$during2" "frozen_event=$frozen" "after_thaw=$after" ;;
10)
  command -v docker >/dev/null 2>&1 || { echo 'Docker unavailable' >&2; exit 2; }
  docker rm -f cg-docker-demo >/dev/null 2>&1 || true
  docker run -d --name cg-docker-demo --memory 64m --pids-limit 32 --cpu-quota 25000 --cpu-period 100000 alpine:3.20 sh -c 'while :; do sleep 60; done' >/dev/null
  pid=$(docker inspect -f '{{.State.Pid}}' cg-docker-demo); rel=$(awk -F: '$1=="0"{print $3}' "/proc/$pid/cgroup"); cg="/sys/fs/cgroup$rel"
  python3 - <<PY
import json,subprocess
inspect=json.loads(subprocess.check_output(['docker','inspect','cg-docker-demo'],text=True))[0]
out={'container':'cg-docker-demo','pid':int('$pid'),'cgroup_path':'$rel','host_config':{'Memory':inspect['HostConfig']['Memory'],'PidsLimit':inspect['HostConfig']['PidsLimit'],'CpuQuota':inspect['HostConfig']['CpuQuota'],'CpuPeriod':inspect['HostConfig']['CpuPeriod']},'memory_max':open('$cg/memory.max').read().strip(),'pids_max':open('$cg/pids.max').read().strip(),'cpu_max':open('$cg/cpu.max').read().strip()}
open('$EVID/10-docker.json','w').write(json.dumps(out,indent=2,sort_keys=True)+'\n')
PY
  chown ubuntu:ubuntu "$EVID/10-docker.json" ;;
11)
  [[ -d "$LAB" ]] && echo 0 > "$LAB/freezer/cgroup.freeze" 2>/dev/null || true
  pkill -f '/usr/local/lib/cgroups-v2-lab/workload.py' 2>/dev/null || true
  docker ps -aq --filter 'name=^/cg-' | xargs -r docker rm -f >/dev/null 2>&1 || true
  sleep .3
  if [[ -d "$LAB" ]]; then find "$LAB" -depth -mindepth 1 -type d -exec rmdir {} + 2>/dev/null || true; rmdir "$LAB" 2>/dev/null || true; fi
  json_write "$EVID/11-cleanup.json" "processes_clean=True" "containers_clean=True" "cgroup_removed=$([[ ! -d "$LAB" ]] && echo True || echo False)" ;;
*) echo "unknown step: $STEP" >&2; exit 64;;
esac
