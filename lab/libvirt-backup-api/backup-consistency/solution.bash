#!/usr/bin/env bash
set -euo pipefail
VM=lab-vm
DIR=/home/ubuntu/backup-consistency
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domfsinfo "$VM" >"$DIR/domfsinfo.txt" 2>&1; then DOMFS=yes; else DOMFS=no; fi
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system qemu-agent-command "$VM" '{"execute":"guest-ping"}' >"$DIR/guest-agent.txt" 2>&1; then AGENT=yes; else AGENT=no; fi
if /usr/bin/test "$DOMFS" = yes && /usr/bin/test "$AGENT" = yes; then /usr/bin/printf 'agent-available\n' >"$DIR/consistency.txt"; else /usr/bin/printf 'crash-consistent-only\n' >"$DIR/consistency.txt"; fi
/usr/bin/printf 'not frozen by this lab\n' >"$DIR/freeze-state.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
