#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-io-wipe
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

/usr/bin/printf 'LIBVIRT_VOLUME_LAB_DATA' >"$DIR/upload.bin"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-upload --pool lab-pool lab-raw.img "$DIR/upload.bin" --offset 0 --length 23 >/dev/null
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-download --pool lab-pool lab-raw.img "$DIR/downloaded-before-wipe.bin" --offset 0 --length 23 >/dev/null
/usr/bin/grep -a 'LIBVIRT_VOLUME_LAB_DATA' "$DIR/downloaded-before-wipe.bin" >"$DIR/downloaded-string.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-wipe --pool lab-pool lab-raw.img --algorithm zero >/dev/null
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-raw.img >"$DIR/vol-info-after-wipe.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
