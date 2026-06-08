#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/emulatorpin
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if /usr/bin/test -s "$STATE_DIR/baseline.env"; then . "$STATE_DIR/baseline.env"; fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system emulatorpin lab-vm > "$DIR/emulatorpin-before.txt" 2> "$DIR/emulatorpin-before.err" || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system emulatorpin lab-vm "${LAB_PIN_MASK:-0}" --live --config > "$DIR/emulatorpin-set.txt" 2> "$DIR/emulatorpin-error.txt" || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system emulatorpin lab-vm > "$DIR/emulatorpin-after.txt" 2>> "$DIR/emulatorpin-error.txt" || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm > "$DIR/domain.xml"
/usr/bin/sed -n '/<cputune>/,/<\/cputune>/p' "$DIR/domain.xml" > "$DIR/cputune.xml" || true
if ! /usr/bin/test -s "$DIR/emulatorpin-error.txt"; then /usr/bin/rm -f "$DIR/emulatorpin-error.txt"; fi

/usr/bin/chown -R ubuntu:ubuntu "$DIR"
