#!/bin/fish
virsh snapshot-create-as --domain student-vm --name clean-install --description 'Clean state' >/dev/null 2>/dev/null; or true
virsh snapshot-list student-vm > /home/ubuntu/snapshot/list.txt 2>/dev/null; or true
