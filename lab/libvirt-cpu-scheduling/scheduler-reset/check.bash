#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/scheduler-reset
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
fail(){ /usr/bin/printf 'Ошибка: %s
' "$1" >&2; exit 1; }
/usr/bin/test -d "$DIR" || fail "нет каталога $DIR"
for f in schedinfo-final.txt vcpupin-final.txt domain-final.xml reset-log.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"; done
if /usr/bin/grep -Eq 'vcpu_quota[[:space:]]*:[[:space:]]*-[[:space:]]*1|vcpu_quota[[:space:]]*:[[:space:]]*-1' "$DIR/schedinfo-final.txt"; then :; else
  /usr/bin/grep -q '<quota>-1</quota>' "$DIR/domain-final.xml" || fail 'жёсткий vCPU throttling не сброшен на -1'
fi
/usr/bin/grep -Eiq 'cpu_shares|Scheduler' "$DIR/schedinfo-final.txt" || fail 'финальный schedinfo некорректен'
