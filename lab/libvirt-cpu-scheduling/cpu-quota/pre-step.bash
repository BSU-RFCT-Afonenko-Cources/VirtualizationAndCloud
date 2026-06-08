#!/usr/bin/env bash
set -euo pipefail
STEP_DIR="/home/ubuntu/cpu-quota"
STATE_DIR="/home/ubuntu/.libvirt-cpu-scheduling"
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$STEP_DIR"
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$STATE_DIR"
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dominfo lab-vm >/dev/null 2>&1; then
  /usr/bin/printf 'Домен lab-vm не найден. Подготовьте учебный домен перед выполнением шага.
' > "$STEP_DIR/pre-step-warning.txt"
  /usr/bin/chown ubuntu:ubuntu "$STEP_DIR/pre-step-warning.txt"
  exit 0
fi
if /usr/bin/test ! -s "$STATE_DIR/baseline.env"; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm > "$STATE_DIR/baseline-schedinfo.txt" 2>&1 || true
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vcpupin lab-vm > "$STATE_DIR/baseline-vcpupin.txt" 2>&1 || true
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm > "$STATE_DIR/baseline-domain.xml" 2>&1 || true
  ONLINE_CPUS="$(/bin/cat /sys/devices/system/cpu/online 2>/dev/null || /usr/bin/printf '0')"
  FIRST_CPU="$(/usr/bin/printf '%s
' "$ONLINE_CPUS" | /usr/bin/awk -F'[-,]' '{print $1}')"
  if /usr/bin/test -z "$FIRST_CPU"; then FIRST_CPU=0; fi
  SHARES="$(/usr/bin/awk '/^[[:space:]]*cpu_shares[[:space:]]*:/ {print $3; found=1} END {if (!found) print "1024"}' "$STATE_DIR/baseline-schedinfo.txt")"
  /usr/bin/printf 'LAB_DOMAIN=lab-vm
LAB_WIDE_MASK=%s
LAB_PIN_MASK=%s
LAB_BASELINE_SHARES=%s
LAB_VCPU_PERIOD=100000
LAB_VCPU_QUOTA=50000
LAB_NEW_SHARES=512
LAB_EMULATOR_PERIOD=100000
LAB_EMULATOR_QUOTA=80000
LAB_GLOBAL_PERIOD=100000
LAB_GLOBAL_QUOTA=90000
' "$ONLINE_CPUS" "$FIRST_CPU" "$SHARES" > "$STATE_DIR/baseline.env"
  /usr/bin/chown -R ubuntu:ubuntu "$STATE_DIR"
fi
