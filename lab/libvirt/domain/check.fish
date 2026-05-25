#!/bin/fish
if not test -f /home/ubuntu/domain/student-vm.xml
  echo 'Нет XML'; exit 1
end
virsh dumpxml student-vm >/tmp/student-vm.xml 2>/dev/null; or begin; echo 'Домен не определён'; exit 1; end
grep -q '<name>student-vm</name>' /tmp/student-vm.xml; or exit 1
grep -Eq "<memory unit='KiB'>([0-9]+)</memory>" /tmp/student-vm.xml; or exit 1
if not grep -q '/home/ubuntu/alpine.iso' /tmp/student-vm.xml
  echo 'ISO alpine не подключен'; exit 1
end
