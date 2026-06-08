#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/cpu-shares
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if /usr/bin/test -s "$STATE_DIR/baseline.env"; then . "$STATE_DIR/baseline.env"; fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm > "$DIR/schedinfo-before.txt"
/usr/bin/awk '/cpu_shares/ {print $3}' "$DIR/schedinfo-before.txt" > "$DIR/cpu-shares-baseline.txt" || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm --set cpu_shares=512 --live --config
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm > "$DIR/schedinfo-after.txt"

/usr/bin/chown -R ubuntu:ubuntu "$DIR"
