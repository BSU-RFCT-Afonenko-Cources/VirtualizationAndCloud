#!/bin/bash
set -uo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
DIAG="$EVIDENCE/diagnostics"
/usr/bin/install -d -o ubuntu -g ubuntu "$DIAG"

docker_available=false; checkpoint_cli=false; criu_available=false; criu_check_ok=false
reasons=()
if docker_ok; then
  docker_available=true
  /usr/bin/docker version >"$DIAG/docker-version.txt" 2>&1
  /usr/bin/docker info >"$DIAG/docker-info.txt" 2>&1
else reasons+=("docker-daemon-unavailable"); fi
if checkpoint_cli_ok; then checkpoint_cli=true; else reasons+=("docker-checkpoint-cli-unavailable"); fi
if CRIU=$(command -v criu 2>/dev/null); then
  criu_available=true
  "$CRIU" --version >"$DIAG/criu-version.txt" 2>&1 || true
  if "$CRIU" check --all >"$DIAG/criu-check.txt" 2>&1; then criu_check_ok=true; else reasons+=("criu-check-failed"); fi
else
  reasons+=("criu-unavailable")
  printf 'criu executable is unavailable\n' >"$DIAG/criu-check.txt"
fi
if test -f /sys/fs/cgroup/cgroup.controllers; then cgroup_version=2; else cgroup_version=1; fi
if $docker_available && $checkpoint_cli && $criu_available && $criu_check_ok; then mode=full; else mode=fallback; fi
printf '%s\n' "$mode" >"$MODE_FILE"
REASONS=$(IFS=,; printf '%s' "${reasons[*]:-}") /usr/bin/python3 - "$docker_available" "$checkpoint_cli" "$criu_available" "$criu_check_ok" "$cgroup_version" "$mode" <<'PY'
import json,os,sys
reasons=[s for s in os.environ.get('REASONS','').split(',') if s]
data={'docker_available':sys.argv[1]=='true','checkpoint_cli':sys.argv[2]=='true','criu_available':sys.argv[3]=='true','criu_check_ok':sys.argv[4]=='true','cgroup_version':int(sys.argv[5]),'mode':sys.argv[6],'reasons':reasons}
json.dump(data,open('/home/ubuntu/cr-lab/evidence/support.json','w'),indent=2)
PY
lab_owner
