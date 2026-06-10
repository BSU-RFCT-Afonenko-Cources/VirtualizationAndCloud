#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-preview-xml
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"

fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/install -d -m 0755 /home/ubuntu/vol-preview-xml/libvirt-lab-pool
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /home/ubuntu/vol-preview-xml/libvirt-lab-pool >/dev/null
fi
/usr/bin/sudo -n /usr/bin/install -d -m 0755 /home/ubuntu/vol-preview-xml/libvirt-lab-pool
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-start lab-pool >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-refresh lab-pool >/dev/null 2>&1 || true

/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-delete --pool lab-pool generated-by-args.qcow2 >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-create-as lab-pool generated-by-args.qcow2 64M --format qcow2 --print-xml >"$DIR/generated-by-args.xml"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool generated-by-args.qcow2 >"$DIR/generated-by-args-vol-info.txt" 2>&1 || true
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
