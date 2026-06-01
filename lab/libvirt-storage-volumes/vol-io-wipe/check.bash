#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-io-wipe
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in upload.bin downloaded-before-wipe.bin downloaded-string.txt vol-info-after-wipe.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
/usr/bin/grep -aq 'LIBVIRT_VOLUME_LAB_DATA' "$DIR/downloaded-before-wipe.bin" || fail "downloaded-before-wipe.bin должен содержать исходную строку"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-raw.img >/dev/null || fail "lab-raw.img должен существовать после wipe"
