#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/cpu-limit-observe
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
fail(){ /usr/bin/printf 'Ошибка: %s
' "$1" >&2; exit 1; }
/usr/bin/test -d "$DIR" || fail "нет каталога $DIR"
for f in schedinfo-current.txt cpu-stats-before.txt cpu-stats-after.txt domstats-vcpu-before.txt domstats-vcpu-after.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"; done
/usr/bin/grep -Eiq 'vcpu_quota|cpu_shares|Scheduler' "$DIR/schedinfo-current.txt" || fail 'scheduler-параметры не сохранены'
/usr/bin/grep -Eiq 'cpu_time|user_time|system_time|[0-9]' "$DIR/cpu-stats-before.txt" || fail 'первый cpu-stats некорректен'
/usr/bin/grep -Eiq 'cpu_time|user_time|system_time|[0-9]' "$DIR/cpu-stats-after.txt" || fail 'второй cpu-stats некорректен'
