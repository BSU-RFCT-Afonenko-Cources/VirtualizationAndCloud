#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-info-physical
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"

fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/install -d -m 0755 /home/ubuntu/vol-info-physical/libvirt-lab-pool
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /home/ubuntu/vol-info-physical/libvirt-lab-pool >/dev/null
fi
/usr/bin/sudo -n /usr/bin/install -d -m 0755 /home/ubuntu/vol-info-physical/libvirt-lab-pool
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-start lab-pool >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-refresh lab-pool >/dev/null 2>&1 || true


if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-disk.qcow2 >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-create-as lab-pool lab-disk.qcow2 256M --format qcow2 >/dev/null
fi
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-sparse.qcow2 >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-create-as lab-pool lab-sparse.qcow2 1G --allocation 0 --format qcow2 >/dev/null
fi
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-raw.img >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-create-as lab-pool lab-raw.img 128M --format raw >/dev/null
fi

/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-sparse.qcow2 --bytes >"$DIR/sparse-info-bytes.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-sparse.qcow2 --bytes --physical >"$DIR/sparse-info-physical.txt" 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-raw.img --bytes >"$DIR/raw-info-bytes.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-raw.img --bytes --physical >"$DIR/raw-info-physical.txt" 2>&1 || true
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
