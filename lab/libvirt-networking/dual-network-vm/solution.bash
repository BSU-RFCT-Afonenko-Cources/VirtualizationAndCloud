#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/dual-network-vm
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >/var/tmp/lab-vm-config.xml
if ! /usr/bin/grep -q '52:54:00:aa:20:01' /var/tmp/lab-vm-config.xml; then
  if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domstate lab-vm | /usr/bin/grep -Eq 'running|работает'; then
    /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system attach-interface lab-vm --type network --source lab-private --model virtio --mac 52:54:00:aa:20:01 --live --config
  else
    /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system attach-interface lab-vm --type network --source lab-private --model virtio --mac 52:54:00:aa:20:01 --config
  fi
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domiflist lab-vm >"$DIR/domiflist.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >"$DIR/lab-vm-config.xml"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-dhcp-leases lab-private >"$DIR/lab-private-leases.txt" 2>&1 || /usr/bin/printf 'no active clients on lab-private\n' >"$DIR/lab-private-leases.txt"
/usr/sbin/bridge link >"$DIR/bridge-link.txt" 2>&1 || /usr/bin/printf 'bridge link unavailable\n' >"$DIR/bridge-link.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
