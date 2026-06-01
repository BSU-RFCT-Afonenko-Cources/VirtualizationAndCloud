#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/dhcp-dns-leases
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-dhcp-leases lab-nat >"$DIR/lab-nat-leases.txt" 2>&1 || /usr/bin/printf 'no active clients on lab-nat\n' >"$DIR/lab-nat-leases.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-dhcp-leases lab-private >"$DIR/lab-private-leases.txt" 2>&1 || /usr/bin/printf 'no active clients on lab-private\n' >"$DIR/lab-private-leases.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domifaddr lab-vm >"$DIR/lab-vm-domifaddr.txt" 2>&1 || /usr/bin/printf 'lab-vm is absent or has no reported addresses\n' >"$DIR/lab-vm-domifaddr.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
