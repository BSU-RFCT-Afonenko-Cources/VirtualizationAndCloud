#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/attach-interface
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in domiflist.txt lab-vm-live.xml lab-vm-config.xml; do /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"; done
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >/home/ubuntu/attach-interface/lab-vm-config.xml 2>/dev/null || fail 'домен lab-vm не определён'
/usr/bin/grep -q "52:54:00:aa:10:01" /home/ubuntu/attach-interface/lab-vm-config.xml || fail 'MAC 52:54:00:aa:10:01 отсутствует в config XML lab-vm'
/usr/bin/grep -A8 -B3 "52:54:00:aa:10:01" /home/ubuntu/attach-interface/lab-vm-config.xml | /usr/bin/grep -q "network='lab-nat'" || fail 'интерфейс с MAC 52:54:00:aa:10:01 должен ссылаться на lab-nat в config XML'
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domstate lab-vm 2>/dev/null | /usr/bin/grep -Eq 'running|работает'; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --live >/home/ubuntu/attach-interface/lab-vm-live.xml
  /usr/bin/grep -q "52:54:00:aa:10:01" /home/ubuntu/attach-interface/lab-vm-live.xml || fail 'MAC отсутствует в live XML запущенного lab-vm'
fi
