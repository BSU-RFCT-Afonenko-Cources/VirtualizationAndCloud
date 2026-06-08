#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vcpupin
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
fail(){ /usr/bin/printf 'Ошибка: %s
' "$1" >&2; exit 1; }
/usr/bin/test -d "$DIR" || fail "нет каталога $DIR"
/usr/bin/test -s "$STATE_DIR/baseline.env" || fail 'нет baseline.env'
. "$STATE_DIR/baseline.env"
/usr/bin/test -s "$DIR/vcpupin-before.txt" || fail 'нет vcpupin-before.txt'
/usr/bin/test -s "$DIR/vcpupin-after.txt" || fail 'нет vcpupin-after.txt'
current=$(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vcpupin lab-vm 2>/dev/null || true)
/bin/echo "$current" | /usr/bin/awk -v mask="$LAB_PIN_MASK" '$1=="0" && $0 ~ mask {found=1} END {exit found?0:1}' || fail "vCPU 0 не закреплён на ожидаемую маску $LAB_PIN_MASK"
