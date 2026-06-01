#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-identity
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"

fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/install -d -m 0755 /tmp/libvirt-lab-pool
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /tmp/libvirt-lab-pool >/dev/null
fi
/usr/bin/sudo -n /usr/bin/install -d -m 0755 /tmp/libvirt-lab-pool
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

/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-path --pool lab-pool lab-disk.qcow2 >"$DIR/vol-path.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-key --pool lab-pool lab-disk.qcow2 >"$DIR/vol-key.txt"
VOL_PATH=$(/usr/bin/cat "$DIR/vol-path.txt")
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-name "$VOL_PATH" >"$DIR/vol-name-by-path.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-pool "$VOL_PATH" >"$DIR/vol-pool-by-path.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
