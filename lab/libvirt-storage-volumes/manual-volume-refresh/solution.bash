#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/manual-volume-refresh
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"

fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/install -d -m 0755 /tmp/libvirt-lab-pool
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /tmp/libvirt-lab-pool >/dev/null
fi
/usr/bin/sudo -n /usr/bin/install -d -m 0755 /tmp/libvirt-lab-pool
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-start lab-pool >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-refresh lab-pool >/dev/null 2>&1 || true

/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-delete --pool lab-pool manual-volume.qcow2 >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/rm -f /tmp/libvirt-lab-pool/manual-volume.qcow2
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-list lab-pool --details >"$DIR/vol-list-before-refresh.txt"
/usr/bin/sudo -n /usr/bin/qemu-img create -f qcow2 /tmp/libvirt-lab-pool/manual-volume.qcow2 32M >/dev/null
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-refresh lab-pool >/dev/null
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-list lab-pool --details >"$DIR/vol-list-after-refresh.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool manual-volume.qcow2 >"$DIR/vol-info-manual-volume.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
