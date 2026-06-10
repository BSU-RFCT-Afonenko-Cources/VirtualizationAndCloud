#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-refresh
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /home/ubuntu/pool-refresh/libvirt-lab-pool >/dev/null; fi
/usr/bin/test -d /home/ubuntu/pool-refresh/libvirt-lab-pool || /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-build lab-pool >/dev/null
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-start lab-pool >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-list lab-pool >"$DIR/vol-list-before.txt"
/usr/bin/sudo -n /usr/bin/qemu-img create -f qcow2 /home/ubuntu/pool-refresh/libvirt-lab-pool/manual.qcow2 64M >/dev/null
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-refresh lab-pool >/dev/null
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-list lab-pool >"$DIR/vol-list-after.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool manual.qcow2 >"$DIR/vol-info-manual.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
