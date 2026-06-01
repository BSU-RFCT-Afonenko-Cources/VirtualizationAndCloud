#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/bridge-tap-diagnostics
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/sbin/ip link show type bridge >"$DIR/bridges.txt" 2>&1
/usr/sbin/bridge link >"$DIR/bridge-link.txt" 2>&1 || /usr/bin/printf 'bridge link unavailable\n' >"$DIR/bridge-link.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domiflist lab-vm >"$DIR/domiflist.txt" 2>&1 || /usr/bin/printf 'lab-vm absent\n' >"$DIR/domiflist.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domifaddr lab-vm >"$DIR/domifaddr.txt" 2>&1 || /usr/bin/printf 'lab-vm absent or no addresses\n' >"$DIR/domifaddr.txt"
/usr/bin/printf 'would run: ping 192.168.100.1 from lab-vm for MAC 52:54:00:aa:10:01\n' >"$DIR/connectivity.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
