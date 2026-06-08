#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vcpupin
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if /usr/bin/test -s "$STATE_DIR/baseline.env"; then . "$STATE_DIR/baseline.env"; fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vcpupin lab-vm > "$DIR/vcpupin-before.txt" || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vcpupin lab-vm 0 "${LAB_PIN_MASK:-0}" --live --config
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vcpupin lab-vm > "$DIR/vcpupin-after.txt"

/usr/bin/chown -R ubuntu:ubuntu "$DIR"
