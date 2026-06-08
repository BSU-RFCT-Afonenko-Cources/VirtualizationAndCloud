#!/usr/bin/env bash
set -euo pipefail
VM=lab-vm
DIR=/home/ubuntu/checkpoint-create
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/cat >"$DIR/checkpoint-manual.xml" <<'XML'
<domaincheckpoint>
  <name>lab-manual-001</name>
</domaincheckpoint>
XML
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system checkpoint-create "$VM" "$DIR/checkpoint-manual.xml" >"$DIR/checkpoint-create.txt" 2>&1; then /usr/bin/printf 'created\n' >"$DIR/result.txt"; else /usr/bin/printf 'unsupported\n' >"$DIR/result.txt"; fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system checkpoint-list "$VM" >"$DIR/checkpoint-list.txt" 2>&1 || /usr/bin/printf 'checkpoint-list unavailable\n' >"$DIR/checkpoint-list.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system checkpoint-list "$VM" --tree >"$DIR/checkpoint-tree.txt" 2>&1 || /usr/bin/printf 'checkpoint tree unavailable\n' >"$DIR/checkpoint-tree.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system checkpoint-dumpxml "$VM" lab-manual-001 >"$DIR/checkpoint-dumpxml.xml" 2>"$DIR/checkpoint-dumpxml.txt" || /usr/bin/test -s "$DIR/checkpoint-dumpxml.txt" || /usr/bin/printf 'lab-manual-001 absent or unsupported\n' >"$DIR/checkpoint-dumpxml.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system checkpoint-parent "$VM" lab-manual-001 >"$DIR/parent.txt" 2>&1 || /usr/bin/printf 'no parent\n' >"$DIR/parent.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
