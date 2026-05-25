#!/bin/fish
if not test -f /home/ubuntu/virt-check/uri.txt
  echo 'Нет /home/ubuntu/virt-check/uri.txt'; exit 1
end
if not test -r /dev/kvm
  echo 'Нет доступа к /dev/kvm'; exit 1
end
if not virsh uri >/dev/null 2>/dev/null
  echo 'Нет подключения virsh'; exit 1
end
if test (egrep -c '(vmx|svm)' /proc/cpuinfo) -eq 0
  echo 'CPU не поддерживает VT'; exit 1
end
