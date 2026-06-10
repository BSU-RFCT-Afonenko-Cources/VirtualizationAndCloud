#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/attach-interface
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >/home/ubuntu/attach-interface/lab-vm-config.xml
if ! /usr/bin/grep -q '52:54:00:aa:10:01' /home/ubuntu/attach-interface/lab-vm-config.xml; then
  if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domstate lab-vm | /usr/bin/grep -Eq 'running|работает'; then
    /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system attach-interface lab-vm --type network --source lab-nat --model virtio --mac 52:54:00:aa:10:01 --live --config
  else
    /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system attach-interface lab-vm --type network --source lab-nat --model virtio --mac 52:54:00:aa:10:01 --config
  fi
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domiflist lab-vm >"$DIR/domiflist.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --live >"$DIR/lab-vm-live.xml" 2>&1 || /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >"$DIR/lab-vm-live.xml"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >"$DIR/lab-vm-config.xml"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
