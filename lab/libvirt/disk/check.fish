#!/bin/fish
if not test -f /home/ubuntu/disk/student-vm.qcow2
  echo 'Нет диска'; exit 1
end
if not qemu-img info /home/ubuntu/disk/student-vm.qcow2 | grep -q 'file format: qcow2'
  echo 'Неверный формат диска'; exit 1
end
if not test -f /home/ubuntu/disk/disk-info.txt
  echo 'Нет файла disk-info.txt'; exit 1
end
