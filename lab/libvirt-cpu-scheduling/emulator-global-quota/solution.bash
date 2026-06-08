#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/emulator-global-quota
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if /usr/bin/test -s "$STATE_DIR/baseline.env"; then . "$STATE_DIR/baseline.env"; fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm > "$DIR/schedinfo-before.txt"
: > "$DIR/quota-error.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm --set emulator_period=100000 --set emulator_quota=80000 --live --config >> "$DIR/quota-set.txt" 2>> "$DIR/quota-error.txt" || /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm --set global_period=100000 --set global_quota=90000 --live --config >> "$DIR/quota-set.txt" 2>> "$DIR/quota-error.txt" || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm > "$DIR/schedinfo-after.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm > "$DIR/domain.xml"
if ! /usr/bin/test -s "$DIR/quota-error.txt"; then /usr/bin/rm -f "$DIR/quota-error.txt"; fi

/usr/bin/chown -R ubuntu:ubuntu "$DIR"
