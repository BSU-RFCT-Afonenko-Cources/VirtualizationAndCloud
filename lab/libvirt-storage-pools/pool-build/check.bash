#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-build
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/target-ls.txt" || fail "нет target-ls.txt"
/usr/bin/test -d /home/ubuntu/pool-build/libvirt-lab-pool || fail "каталог /home/ubuntu/pool-build/libvirt-lab-pool не создан"
/usr/bin/test -x /home/ubuntu/pool-build/libvirt-lab-pool || fail "нет права прохода в target directory"
/usr/bin/test -w /home/ubuntu/pool-build/libvirt-lab-pool || fail "нет права записи в target directory для root/libvirt"
/usr/bin/grep -q 'libvirt-lab-pool' "$DIR/target-ls.txt" || fail "target-ls.txt должен содержать строку ls -ld для target"
