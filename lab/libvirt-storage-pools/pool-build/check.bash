#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-build
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/target-ls.txt" || fail "нет target-ls.txt"
/usr/bin/test -d /tmp/libvirt-lab-pool || fail "каталог /tmp/libvirt-lab-pool не создан"
/usr/bin/test -x /tmp/libvirt-lab-pool || fail "нет права прохода в target directory"
/usr/bin/test -w /tmp/libvirt-lab-pool || fail "нет права записи в target directory для root/libvirt"
/usr/bin/grep -q 'libvirt-lab-pool' "$DIR/target-ls.txt" || fail "target-ls.txt должен содержать строку ls -ld для target"
