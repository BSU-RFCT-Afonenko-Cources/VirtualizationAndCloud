#!/usr/bin/env bash
set -euo pipefail
CG=/sys/fs/cgroup
LAB=/sys/fs/cgroup/cg-lab
HOME_DIR=/home/ubuntu/cgroups-v2-lab
LIB=/usr/local/lib/cgroups-v2-lab
STATE=/run/cgroups-v2-lab
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(stat -fc %T "$CG")" != cgroup2fs ]] || [[ ! -f "$CG/cgroup.controllers" ]]; then
  printf 'ERROR: this lab requires a unified cgroup v2 hierarchy mounted at %s; legacy/mixed mode is unsupported and will not be reconfigured.\n' "$CG" >&2
  exit 2
fi
for controller in cpu memory pids; do
  if ! tr ' ' '\n' < "$CG/cgroup.controllers" | grep -qx "$controller"; then
    printf 'ERROR: required cgroup v2 controller %s is not available at %s.\n' "$controller" "$CG" >&2
    exit 3
  fi
done

install -d -m 0755 "$LIB" "$STATE"
install -m 0755 "$SCRIPT_DIR/assets/workload.py" "$LIB/workload.py"
install -m 0755 "$SCRIPT_DIR/scripts/check.bash" "$LIB/check.bash"
install -m 0755 "$SCRIPT_DIR/scripts/solution.bash" "$LIB/solution.bash"
install -m 0755 "$SCRIPT_DIR/scripts/pre-step.bash" "$LIB/pre-step.bash"
install -m 0755 "$SCRIPT_DIR/scripts/post-step.bash" "$LIB/post-step.bash"
install -d -o ubuntu -g ubuntu -m 0755 "$HOME_DIR" "$HOME_DIR/evidence" "$HOME_DIR/io-data"

# Remove leftovers only inside the lab-owned branch.
if [[ -d "$LAB" ]]; then
  [[ -f "$LAB/cgroup.freeze" ]] && printf '0\n' > "$LAB/cgroup.freeze" || true
  while IFS= read -r pid; do kill "$pid" 2>/dev/null || true; done < <(find "$LAB" -name cgroup.procs -type f -exec cat {} + 2>/dev/null)
  find "$LAB" -depth -mindepth 1 -type d -exec rmdir {} + 2>/dev/null || true
  rmdir "$LAB" 2>/dev/null || true
fi
if ! mkdir "$LAB" 2>/dev/null; then
  printf 'ERROR: cannot create %s. The cgroup filesystem is probably read-only or not delegated in this environment; run the lab in the prepared VM or provide read-only evidence for step 01 only.\n' "$LAB" >&2
  exit 5
fi
root_available="$(cat "$CG/cgroup.controllers")"
for controller in cpu memory pids io cpuset; do
  if tr ' ' '\n' <<<"$root_available" | grep -qx "$controller"; then
    printf '+%s\n' "$controller" > "$CG/cgroup.subtree_control" 2>/dev/null || true
  fi
done
available="$(cat "$LAB/cgroup.controllers")"
for controller in cpu memory pids io cpuset; do
  if tr ' ' '\n' <<<"$available" | grep -qx "$controller"; then
    printf '+%s\n' "$controller" > "$LAB/cgroup.subtree_control" || true
  fi
done
for required in cpu memory pids; do
  if ! tr ' ' '\n' <<<"$available" | grep -qx "$required"; then
    printf 'ERROR: controller %s is not delegated to %s; cannot run resource-limit experiments safely.\n' "$required" "$LAB" >&2
    exit 4
  fi
done
chown ubuntu:ubuntu "$LAB" "$LAB/cgroup.procs" "$LAB/cgroup.subtree_control"
printf '%s\n' "$available" > "$STATE/root-controllers"
chown -R ubuntu:ubuntu "$HOME_DIR"

if command -v docker >/dev/null 2>&1; then
  docker rm -f cg-docker-demo >/dev/null 2>&1 || true
  docker image inspect alpine:3.20 >/dev/null 2>&1 || docker pull alpine:3.20 >/dev/null 2>&1 || printf 'WARNING: alpine:3.20 is not cached and could not be pulled; step 10 solution will need that image.\n' >&2
else
  printf 'WARNING: Docker is unavailable; steps 1-9 remain usable, but step 10 cannot be completed.\n' >&2
fi
printf 'cgroup v2 lab prepared at %s\n' "$LAB"
