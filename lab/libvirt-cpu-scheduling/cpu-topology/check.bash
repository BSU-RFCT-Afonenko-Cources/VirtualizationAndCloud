#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/cpu-topology
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
fail(){ /usr/bin/printf 'Ошибка: %s
' "$1" >&2; exit 1; }
/usr/bin/test -d "$DIR" || fail "нет каталога $DIR"
for f in nodeinfo.txt capabilities.xml vcpucount.txt vcpuinfo.txt cpu-stats-total.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"; done
/usr/bin/grep -Eiq 'CPU model|Модель CPU|CPU\(s\)|CPU socket|Core\(s\) per socket|Thread\(s\) per core' "$DIR/nodeinfo.txt" || fail 'nodeinfo.txt не содержит CPU model/topology'
/usr/bin/grep -Eq '<host>|<cpu>|<topology|<model' "$DIR/capabilities.xml" || fail 'capabilities.xml не содержит host CPU topology'
/usr/bin/grep -Eiq 'maximum|current|config|live|[0-9]+' "$DIR/vcpucount.txt" || fail 'vcpucount.txt не содержит количество vCPU'
/usr/bin/grep -Eiq 'VCPU|CPU|State|Состояние' "$DIR/vcpuinfo.txt" || fail 'vcpuinfo.txt не содержит информацию vCPU'
/usr/bin/grep -Eiq 'cpu_time|user_time|system_time|[0-9]' "$DIR/cpu-stats-total.txt" || fail 'cpu-stats-total.txt не содержит baseline CPU stats'
