#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/schedinfo-read
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm > "$DIR/schedinfo.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm > "$DIR/domain.xml"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm | /usr/bin/sed -n '/<cputune>/,/<\/cputune>/p' > "$DIR/cputune.xml"
if ! /usr/bin/test -s "$DIR/cputune.xml"; then /usr/bin/printf '<cputune> отсутствует в baseline XML lab-vm
' > "$DIR/cputune-absent.txt"; fi
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
