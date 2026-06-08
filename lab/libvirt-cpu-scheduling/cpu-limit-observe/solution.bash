#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/cpu-limit-observe
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if /usr/bin/test -s "$STATE_DIR/baseline.env"; then . "$STATE_DIR/baseline.env"; fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm > "$DIR/schedinfo-current.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system cpu-stats lab-vm --total > "$DIR/cpu-stats-before.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domstats lab-vm --vcpu > "$DIR/domstats-vcpu-before.txt" || true
/bin/sleep 5
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system cpu-stats lab-vm --total > "$DIR/cpu-stats-after.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domstats lab-vm --vcpu > "$DIR/domstats-vcpu-after.txt" || true
/usr/bin/printf 'Использована безопасная пауза наблюдения; guest load optional.
' > "$DIR/load-note.txt"

/usr/bin/chown -R ubuntu:ubuntu "$DIR"
