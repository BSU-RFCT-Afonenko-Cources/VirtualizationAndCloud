#!/bin/bash
set -u

LAB=/home/ubuntu/cr-lab
EVIDENCE=/home/ubuntu/cr-lab/evidence
STATE=/home/ubuntu/cr-lab/state
CHECKPOINTS=/home/ubuntu/cr-lab/checkpoints
MODE_FILE=/home/ubuntu/cr-lab/mode
IMAGE=cr-demo-counter:lab

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
pass() { printf 'OK: %s\n' "$*"; }
need_file() { test -f "$1" || fail "missing file $1"; }
json_get() { /usr/bin/python3 - "$1" "$2" <<'PY'
import json, sys
value=json.load(open(sys.argv[1], encoding='utf-8'))
for part in sys.argv[2].split('.'):
    value=value[int(part)] if isinstance(value, list) else value[part]
print(str(value).lower() if isinstance(value, bool) else value)
PY
}
write_json() { /usr/bin/python3 - "$@"; }
lab_owner() { /bin/chown -R ubuntu:ubuntu "$LAB"; }
docker_ok() { /usr/bin/docker info >/dev/null 2>&1; }
checkpoint_cli_ok() { /usr/bin/docker checkpoint create --help >/dev/null 2>&1; }
full_mode() { test -f "$MODE_FILE" && test "$(/bin/cat "$MODE_FILE")" = full; }
container_exists() { /usr/bin/docker inspect "$1" >/dev/null 2>&1; }
container_running() { test "$(/usr/bin/docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null)" = true; }
state_counter() { json_get "$1" counter; }
