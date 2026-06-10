#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/network-cleanup
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
for mac in 52:54:00:aa:10:01 52:54:00:aa:20:01; do
  if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >/home/ubuntu/network-cleanup/lab-vm-clean.xml 2>/dev/null && /usr/bin/grep -q "$mac" /home/ubuntu/network-cleanup/lab-vm-clean.xml; then
    /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system detach-interface lab-vm --type network --mac "$mac" --config || true
  fi
  if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domstate lab-vm 2>/dev/null | /usr/bin/grep -Eq 'running|работает'; then
    /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system detach-interface lab-vm --type network --mac "$mac" --live || true
  fi
done
for net in lab-nat lab-private; do
  if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info "$net" >/dev/null 2>&1; then
    /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-autostart "$net" --disable || true
    if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info "$net" | /usr/bin/grep -Eq 'Active:[[:space:]]+yes|Активна:[[:space:]]+да|Активна:[[:space:]]+yes'; then
      /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-destroy "$net"
    fi
    /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-undefine "$net"
  fi
done
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-list --all >"$DIR/net-list-final.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >"$DIR/lab-vm-final.xml" 2>&1 || /usr/bin/printf 'lab-vm absent\n' >"$DIR/lab-vm-final.xml"
/usr/sbin/ip link show >"$DIR/links-final.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
