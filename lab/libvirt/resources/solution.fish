#!/bin/fish
virsh setmaxmem student-vm 480M --config >/dev/null 2>/dev/null; or true
virsh setmem student-vm 480M --config >/dev/null 2>/dev/null; or true
virsh setvcpus student-vm 2 --config >/dev/null 2>/dev/null; or true
virsh dominfo student-vm > /home/ubuntu/resources/dominfo.txt 2>/dev/null; or true
