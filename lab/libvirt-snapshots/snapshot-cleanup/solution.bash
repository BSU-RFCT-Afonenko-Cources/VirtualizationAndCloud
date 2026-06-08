#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-cleanup
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
BASE=$(/usr/bin/sed -n 's/^BASE_DISK=//p' /home/ubuntu/snapshot-baseline/baseline.env)
/usr/bin/test -n "$BASE"
: >"$DIR/cleanup-results.txt"
STATE=$(/usr/bin/virsh -c qemu:///system domstate lab-vm 2>&1 || true)
if ! /usr/bin/printf '%s\n' "$STATE" | /usr/bin/grep -Eqi 'running|работает'; then /usr/bin/virsh -c qemu:///system start lab-vm >>"$DIR/cleanup-results.txt"; fi
COUNT=0
while /usr/bin/test "$COUNT" -lt 32; do
  ACTIVE=$(/usr/bin/virsh -c qemu:///system domblklist lab-vm --details | /usr/bin/awk '$3=="vda"{print $4; exit}')
  /usr/bin/test -n "$ACTIVE"
  if /usr/bin/test "$ACTIVE" = "$BASE"; then break; fi
  case "$ACTIVE" in /tmp/libvirt-snapshots/lab-*.qcow2) ;; *) /usr/bin/printf 'refusing to commit unexpected active source %s\n' "$ACTIVE" >&2; exit 1;; esac
  /usr/bin/virsh -c qemu:///system blockcommit lab-vm vda --active --pivot --verbose >>"$DIR/cleanup-results.txt" 2>&1
  COUNT=$((COUNT+1))
done
ACTIVE=$(/usr/bin/virsh -c qemu:///system domblklist lab-vm --details | /usr/bin/awk '$3=="vda"{print $4; exit}')
/usr/bin/test "$ACTIVE" = "$BASE"
COUNT=0
while /usr/bin/test "$COUNT" -lt 64; do
  NAME=$(/usr/bin/virsh -c qemu:///system snapshot-list lab-vm --name --leaves 2>/dev/null | /usr/bin/grep '^lab-' | /usr/bin/head -n 1 || true)
  if /usr/bin/test -z "$NAME"; then NAME=$(/usr/bin/virsh -c qemu:///system snapshot-list lab-vm --name | /usr/bin/grep '^lab-' | /usr/bin/tail -n 1 || true); fi
  /usr/bin/test -n "$NAME" || break
  /usr/bin/virsh -c qemu:///system snapshot-delete lab-vm "$NAME" --metadata >>"$DIR/cleanup-results.txt" 2>&1
  COUNT=$((COUNT+1))
done
while IFS= read -r FILE; do /usr/bin/test "$FILE" = "$ACTIVE" || /usr/bin/rm -f -- "$FILE"; done < <(/usr/bin/find /tmp/libvirt-snapshots -maxdepth 1 -type f \( -name 'lab-*.qcow2' -o -name 'lab-*.memory' \) -print)
/usr/bin/virsh -c qemu:///system snapshot-list lab-vm --name >"$DIR/snapshot-list-final.txt"
/usr/bin/test -s "$DIR/snapshot-list-final.txt" || /usr/bin/printf '(no snapshots)\n' >"$DIR/snapshot-list-final.txt"
/usr/bin/virsh -c qemu:///system domblklist lab-vm --details >"$DIR/domblklist-final.txt"
/usr/bin/qemu-img info "$ACTIVE" >"$DIR/disk-info-final.txt"
/usr/bin/test -s "$DIR/cleanup-results.txt" || /usr/bin/printf 'snapshot chain already clean\n' >"$DIR/cleanup-results.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
