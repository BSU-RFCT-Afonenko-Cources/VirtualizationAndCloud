#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-start-autostart
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /home/ubuntu/pool-start-autostart/libvirt-lab-pool >/dev/null; fi
/usr/bin/test -d /home/ubuntu/pool-start-autostart/libvirt-lab-pool || /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-build lab-pool >/dev/null
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-start lab-pool >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-autostart lab-pool >/dev/null
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >"$DIR/pool-info-lab-pool.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-list --autostart >"$DIR/pool-list-autostart.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
