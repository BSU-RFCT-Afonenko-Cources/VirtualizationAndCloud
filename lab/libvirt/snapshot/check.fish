#!/bin/fish
virsh snapshot-list student-vm 2>/dev/null | grep -q clean-install; or exit 1
test -f /home/ubuntu/snapshot/list.txt; or exit 1
