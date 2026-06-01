#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/interface-qos
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domiftune lab-vm 52:54:00:aa:10:01 --config >"$DIR/domiftune-before.txt" 2>&1 || /usr/bin/printf 'no existing tune\n' >"$DIR/domiftune-before.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domiftune lab-vm 52:54:00:aa:10:01 --inbound 1024,2048,512 --outbound 1024,2048,512 --config
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domstate lab-vm | /usr/bin/grep -Eq 'running|работает'; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domiftune lab-vm 52:54:00:aa:10:01 --inbound 1024,2048,512 --outbound 1024,2048,512 --live || true
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domiftune lab-vm 52:54:00:aa:10:01 --config >"$DIR/domiftune-after.txt" 2>&1
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >"$DIR/lab-vm-config.xml"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
