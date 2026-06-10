#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-delete-cleanup
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"

fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/install -d -m 0755 /home/ubuntu/vol-delete-cleanup/libvirt-lab-pool
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /home/ubuntu/vol-delete-cleanup/libvirt-lab-pool >/dev/null
fi
/usr/bin/sudo -n /usr/bin/install -d -m 0755 /home/ubuntu/vol-delete-cleanup/libvirt-lab-pool
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-start lab-pool >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-refresh lab-pool >/dev/null 2>&1 || true

for vol in lab-overlay.qcow2 lab-disk-clone.qcow2 lab-from-xml.qcow2 lab-sparse.qcow2 lab-raw.img lab-disk.qcow2 manual-volume.qcow2 generated-by-args.qcow2 lab-disk-reflink-preview.qcow2; do
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-delete --pool lab-pool "$vol" >/dev/null 2>&1 || true
  /usr/bin/sudo -n /usr/bin/rm -f "/home/ubuntu/vol-delete-cleanup/libvirt-lab-pool/$vol" >/dev/null 2>&1 || true
done
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-refresh lab-pool >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-list lab-pool --details >"$DIR/final-vol-list-details.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
