#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-consistency
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in domfsinfo.txt guest-agent.txt consistency.txt freeze-state.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
/usr/bin/grep -Eq 'agent-available|crash-consistent-only' "$DIR/consistency.txt" || fail 'неверный consistency.txt'
/usr/bin/grep -qi 'not frozen\|thawed\|not.*freeze' "$DIR/freeze-state.txt" || fail 'freeze-state.txt не подтверждает отсутствие frozen state'
