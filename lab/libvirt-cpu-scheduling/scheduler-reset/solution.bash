#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/scheduler-reset
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if /usr/bin/test -s "$STATE_DIR/baseline.env"; then . "$STATE_DIR/baseline.env"; fi
/usr/bin/printf 'Reset CPU scheduler policy for lab-vm
' > "$DIR/reset-log.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm --set vcpu_quota=-1 --live --config >> "$DIR/reset-log.txt" 2>&1
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm --set emulator_quota=-1 --live --config >> "$DIR/reset-log.txt" 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm --set global_quota=-1 --live --config >> "$DIR/reset-log.txt" 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm --set cpu_shares="${LAB_BASELINE_SHARES:-1024}" --live --config >> "$DIR/reset-log.txt" 2>&1 || true
vcpu_count="$(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vcpucount lab-vm --current 2>/dev/null | /usr/bin/awk 'NR==1 {print $1}')"
if ! /usr/bin/awk 'BEGIN{exit !(ARGV[1] ~ /^[0-9]+$/)}' "$vcpu_count"; then vcpu_count=1; fi
i=0
while /usr/bin/test "$i" -lt "$vcpu_count"; do
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vcpupin lab-vm "$i" "${LAB_WIDE_MASK:-0}" --live --config >> "$DIR/reset-log.txt" 2>&1 || true
  i=$((i+1))
done
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system emulatorpin lab-vm "${LAB_WIDE_MASK:-0}" --live --config >> "$DIR/reset-log.txt" 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm > "$DIR/schedinfo-final.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vcpupin lab-vm > "$DIR/vcpupin-final.txt" || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm > "$DIR/domain-final.xml"

/usr/bin/chown -R ubuntu:ubuntu "$DIR"
