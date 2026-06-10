#!/bin/fish
virsh dumpxml student-vm >/home/ubuntu/resources/student-vm.xml 2>/dev/null; or exit 1
grep -Eq '<vcpu[^>]*>2</vcpu>' /home/ubuntu/resources/student-vm.xml; or exit 1
grep -Eq "<memory unit='MiB'>480</memory>|<memory unit='KiB'>491520</memory>" /home/ubuntu/resources/student-vm.xml; or exit 1
test -f /home/ubuntu/resources/dominfo.txt; or exit 1
