#!/bin/fish
qemu-img create -f qcow2 /home/ubuntu/disk/student-vm.qcow2 1G >/dev/null
qemu-img info /home/ubuntu/disk/student-vm.qcow2 > /home/ubuntu/disk/disk-info.txt
