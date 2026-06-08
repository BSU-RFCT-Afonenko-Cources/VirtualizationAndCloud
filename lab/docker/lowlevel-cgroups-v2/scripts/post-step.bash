#!/usr/bin/env bash
set -euo pipefail
STEP="${1:?step}"
LAB=/sys/fs/cgroup/cg-lab
HOME_DIR=/home/ubuntu/cgroups-v2-lab
json_pid(){ python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("pid", ""))' "$1" 2>/dev/null || true; }
case "$STEP" in
  02) pid="$(json_pid "$HOME_DIR/evidence/02-membership.json")"; [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true ;;
  08) pid="$(json_pid "$HOME_DIR/evidence/08-cpuset.json")"; [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true ;;
  09) [[ -d "$LAB/freezer" ]] && printf '0\n' > "$LAB/freezer/cgroup.freeze" 2>/dev/null || true; pid="$(json_pid "$HOME_DIR/evidence/09-freezer.json")"; [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true ;;
  10) docker rm -f cg-docker-demo >/dev/null 2>&1 || true ;;
esac
