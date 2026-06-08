#!/usr/bin/env bash
set -euo pipefail
STEP="${1:?step}"
LAB=/sys/fs/cgroup/cg-lab
HOME_DIR=/home/ubuntu/cgroups-v2-lab
[[ -d "$LAB" ]] || { printf 'Run prepare first: %s does not exist.\n' "$LAB" >&2; exit 2; }
install -d -o ubuntu -g ubuntu -m 0755 "$HOME_DIR/evidence" "$HOME_DIR/io-data"
case "$STEP" in
  02) rm -f "$HOME_DIR/evidence/02-membership.json" ;;
  03) rm -rf "$LAB/cpu-weight"; rm -f "$HOME_DIR/evidence/03-cpu-weight.json" ;;
  04) rm -rf "$LAB/cpu-limited"; rm -f "$HOME_DIR/evidence/04-cpu-max.json" ;;
  05) rm -rf "$LAB/memory"; rm -f "$HOME_DIR/evidence/05-memory.json" ;;
  06) rm -rf "$LAB/pids"; rm -f "$HOME_DIR/evidence/06-pids.json" ;;
  07) rm -rf "$LAB/io"; rm -f "$HOME_DIR/evidence/07-io.json" "$HOME_DIR/io-data/write.bin" ;;
  08) rm -rf "$LAB/cpuset"; rm -f "$HOME_DIR/evidence/08-cpuset.json" ;;
  09) rm -rf "$LAB/freezer"; rm -f "$HOME_DIR/evidence/09-freezer.json" "$HOME_DIR/freezer.counter" ;;
  10) docker rm -f cg-docker-demo >/dev/null 2>&1 || true; rm -f "$HOME_DIR/evidence/10-docker.json" ;;
esac
