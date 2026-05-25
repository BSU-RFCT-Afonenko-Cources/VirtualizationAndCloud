#!/bin/fish
cp /home/ubuntu/disk/student-vm.qcow2 /home/ubuntu/backup/student-vm-backup.qcow2 2>/dev/null; or true
virsh dumpxml student-vm > /home/ubuntu/backup/student-vm.xml 2>/dev/null; or true
