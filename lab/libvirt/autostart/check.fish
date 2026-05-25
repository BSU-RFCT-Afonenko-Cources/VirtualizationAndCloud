#!/bin/fish
virsh dominfo student-vm 2>/dev/null | grep -q "Autostart:[[:space:]]*enable"; or virsh dominfo student-vm 2>/dev/null | grep -q "Autostart:[[:space:]]*yes"; or exit 1
test -f /home/ubuntu/autostart/dominfo.txt; or exit 1
