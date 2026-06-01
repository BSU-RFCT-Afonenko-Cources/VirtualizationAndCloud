#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/prepare-volume-pool
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/pool-info.txt" || fail "нет pool-info.txt"
/usr/bin/test -s "$DIR/vol-list-details.txt" || fail "нет vol-list-details.txt"
STATE=$(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool | /usr/bin/awk -F: '/State/{gsub(/^[ 	]+/,"",$2); print $2}')
TYPE=$(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-dumpxml --xpath 'string(/pool/@type)' lab-pool)
TARGET=$(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-dumpxml --xpath 'string(/pool/target/path)' lab-pool)
/usr/bin/test "$STATE" = "running" || fail "lab-pool должен быть active/running"
/usr/bin/test "$TYPE" = "dir" || fail "lab-pool должен иметь type dir"
/usr/bin/test "$TARGET" = "/tmp/libvirt-lab-pool" || fail "target path должен быть /tmp/libvirt-lab-pool"
/usr/bin/test -d /tmp/libvirt-lab-pool || fail "target path недоступен"
