#!/bin/fish
virsh autostart student-vm >/dev/null 2>/dev/null; or true
virsh dominfo student-vm > /home/ubuntu/autostart/dominfo.txt 2>/dev/null; or true
