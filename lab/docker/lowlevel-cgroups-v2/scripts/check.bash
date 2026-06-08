#!/usr/bin/env bash
set -euo pipefail
STEP="${1:?step}"
LAB=/sys/fs/cgroup/cg-lab
HOME_DIR=/home/ubuntu/cgroups-v2-lab
EVID="$HOME_DIR/evidence"
fail(){ printf 'CHECK FAILED: %s\n' "$*" >&2; exit 1; }
json_get(){ python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get(sys.argv[2],""))' "$1" "$2"; }
json_assert(){ python3 - "$@" <<'PY'
import json,sys,operator
path,expr=sys.argv[1],sys.argv[2]
data=json.load(open(path))
if not eval(expr, {'__builtins__':{}}, {'d':data, 'open':open, 'set':set, 'isinstance':isinstance, 'list':list}):
    raise SystemExit(f'assertion failed: {expr}')
PY
}
need_file(){ [[ -s "$1" ]] || fail "missing non-empty evidence file: $1"; python3 -m json.tool "$1" >/dev/null || fail "invalid JSON: $1"; }
stat_field(){ awk -v k="$2" '$1==k{print $2}' "$1"; }
case "$STEP" in
01)
  f="$EVID/01-mode.json"; need_file "$f"
  [[ "$(stat -fc %T /sys/fs/cgroup)" == cgroup2fs ]] || fail '/sys/fs/cgroup is not cgroup2fs'
  json_assert "$f" "d.get('mode')=='unified' and d.get('mount_type')=='cgroup2fs' and isinstance(d.get('controllers'),list) and set(d.get('controllers',[]))==set(open('/sys/fs/cgroup/cgroup.controllers').read().split())" ;;
02)
  f="$EVID/02-membership.json"; need_file "$f"; pid=$(json_get "$f" pid)
  [[ -d "$LAB/membership" ]] || fail 'membership cgroup is absent'
  [[ -d "/proc/$pid" ]] || fail "PID $pid is not alive"
  grep -qx "$pid" "$LAB/membership/cgroup.procs" || fail "PID $pid is not in membership/cgroup.procs"
  grep -qx '0::/cg-lab/membership' "/proc/$pid/cgroup" || fail "PID $pid has unexpected cgroup" ;;
03)
  f="$EVID/03-cpu-weight.json"; need_file "$f"
  [[ "$(cat "$LAB/cpu-weight/low/cpu.weight")" == 10 ]] || fail 'low cpu.weight mismatch'
  [[ "$(cat "$LAB/cpu-weight/high/cpu.weight")" == 1000 ]] || fail 'high cpu.weight mismatch'
  json_assert "$f" "d.get('high_usage_delta_usec',0) > d.get('low_usage_delta_usec',0) and d.get('ratio',0) >= 1.5" ;;
04)
  f="$EVID/04-cpu-max.json"; need_file "$f"
  [[ "$(cat "$LAB/cpu-limited/cpu.max")" == '20000 100000' ]] || fail 'cpu.max mismatch'
  json_assert "$f" "d.get('nr_throttled_delta',0) > 0 or d.get('throttled_usec_delta',0) > 0" ;;
05)
  f="$EVID/05-memory.json"; need_file "$f"
  [[ "$(cat "$LAB/memory/memory.max")" == $((32*1024*1024)) ]] || fail 'memory.max mismatch'
  json_assert "$f" "d.get('events_delta',{}).get('max',0) > 0 or d.get('events_delta',{}).get('oom',0) > 0 or d.get('events_delta',{}).get('oom_kill',0) > 0 or d.get('exit_code')==42" ;;
06)
  f="$EVID/06-pids.json"; need_file "$f"
  [[ "$(cat "$LAB/pids/pids.max")" == 16 ]] || fail 'pids.max mismatch'
  [[ "$(cat "$LAB/pids/pids.current")" == 0 ]] || fail 'pids cgroup still contains processes'
  json_assert "$f" "d.get('max_events_delta',0) > 0 and d.get('cleanup_ok') is True" ;;
07)
  f="$EVID/07-io.json"; need_file "$f"; status=$(json_get "$f" status)
  if [[ "$status" == supported ]]; then
    [[ -f "$LAB/io/io.max" && -f "$LAB/io/io.stat" ]] || fail 'io files disappeared'
    json_assert "$f" "d.get('bytes_written',0) >= 1024*1024 and d.get('io_stat_after','') != ''"
  elif [[ "$status" == unsupported ]]; then
    json_assert "$f" "d.get('reason','') != ''"
  else fail "invalid io status: $status"; fi ;;
08)
  f="$EVID/08-cpuset.json"; need_file "$f"; pid=$(json_get "$f" pid)
  [[ -d "/proc/$pid" ]] || fail "PID $pid is not alive"
  aff=$(awk -F'\t' '/Cpus_allowed_list/{print $2}' "/proc/$pid/status")
  [[ "$aff" == "$(cat "$LAB/cpuset/cpuset.cpus.effective")" || "$aff" == "$(json_get "$f" configured_cpus)" ]] || fail "affinity $aff is not the configured/effective cpuset" ;;
09)
  f="$EVID/09-freezer.json"; need_file "$f"; [[ "$(cat "$LAB/freezer/cgroup.freeze")" == 0 ]] || fail 'freezer was not thawed'
  json_assert "$f" "d.get('during_freeze_1') == d.get('during_freeze_2') and d.get('frozen_event') == 1 and d.get('after_thaw',0) > d.get('during_freeze_2',0)" ;;
10)
  f="$EVID/10-docker.json"; need_file "$f"
  docker inspect cg-docker-demo >/dev/null 2>&1 || fail 'container cg-docker-demo is absent'
  pid=$(json_get "$f" pid); [[ -d "/proc/$pid" ]] || fail "container init PID $pid is not alive"
  rel=$(awk -F: '$1=="0"{print $3}' "/proc/$pid/cgroup"); cg="/sys/fs/cgroup$rel"
  [[ "$(cat "$cg/memory.max")" == 67108864 ]] || fail 'container memory.max mismatch'
  [[ "$(cat "$cg/pids.max")" == 32 ]] || fail 'container pids.max mismatch'
  [[ "$(cat "$cg/cpu.max")" == '25000 100000' ]] || fail 'container cpu.max mismatch'
  json_assert "$f" "d.get('host_config',{}).get('Memory') == 67108864 and d.get('host_config',{}).get('PidsLimit') == 32" ;;
11)
  f="$EVID/11-cleanup.json"; need_file "$f"
  [[ ! -d "$LAB" ]] || fail 'lab cgroup still exists'
  pgrep -f '/usr/local/lib/cgroups-v2-lab/workload.py' >/dev/null && fail 'lab workload processes are still running'
  if command -v docker >/dev/null 2>&1; then [[ -z "$(docker ps -aq --filter 'name=^/cg-')" ]] || fail 'cg-* Docker containers remain'; fi
  json_assert "$f" "d.get('processes_clean') is True and d.get('containers_clean') is True and d.get('cgroup_removed') is True" ;;
*) fail "unknown step: $STEP";;
esac
printf 'OK step %s\n' "$STEP"
