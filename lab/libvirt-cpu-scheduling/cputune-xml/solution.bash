#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/cputune-xml
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if /usr/bin/test -s "$STATE_DIR/baseline.env"; then . "$STATE_DIR/baseline.env"; fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm > "$DIR/domain.xml"
/usr/bin/sed -n '/<cputune>/,/<\/cputune>/p' "$DIR/domain.xml" > "$DIR/cputune.xml" || true
/usr/bin/grep -nE '<cputune>|<vcpupin|<emulatorpin|<shares>|<period>|<quota>|<emulator_period>|<emulator_quota>|<global_period>|<global_quota>' "$DIR/domain.xml" > "$DIR/cputune-grep.txt" || true
if ! /usr/bin/grep -Eq '<vcpupin|<shares>|<period>|<quota>|<emulatorpin|<emulator_period>|<global_period' "$DIR/cputune-grep.txt"; then /usr/bin/printf 'Некоторые элементы cputune отсутствуют или не поддерживаются в этом окружении.
' > "$DIR/unsupported-elements.txt"; fi

/usr/bin/chown -R ubuntu:ubuntu "$DIR"
