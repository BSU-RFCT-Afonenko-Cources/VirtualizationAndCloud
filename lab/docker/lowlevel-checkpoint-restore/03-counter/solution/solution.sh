#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
BIN="$LAB/bin/cr-demo-counter"; HOST_STATE="$STATE/host"; RUN="$LAB/run"
test -x "$BIN" || fail "counter binary was not built; gcc is required"
/usr/bin/install -d -o ubuntu -g ubuntu "$HOST_STATE" "$RUN"
if test -f "$RUN/host.pid" && /bin/kill -0 "$(/bin/cat "$RUN/host.pid")" 2>/dev/null; then /bin/kill "$(/bin/cat "$RUN/host.pid")" || true; /bin/sleep 1; fi
/usr/sbin/start-stop-daemon --start --background --make-pidfile --pidfile "$RUN/host.pid" --chuid ubuntu:ubuntu --chdir "$LAB" --startas "$BIN" -- "$HOST_STATE" 18081
/bin/chown ubuntu:ubuntu "$RUN/host.pid"
for _ in $(/usr/bin/seq 1 30); do test -s "$HOST_STATE/state.json" && break; /bin/sleep 0.2; done
