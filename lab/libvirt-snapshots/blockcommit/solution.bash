#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/blockcommit
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
ACTIVE=$(/usr/bin/virsh -c qemu:///system domblklist lab-vm --details | /usr/bin/awk '$3=="vda"{print $4; exit}')
/usr/bin/printf '%s\n' "$ACTIVE" >"$DIR/active-before.txt"
BACKING=$(/usr/bin/qemu-img info --output=json "$ACTIVE" | /usr/bin/python3 -c 'import json,sys; print(json.load(sys.stdin).get("full-backing-filename", ""))')
/usr/bin/printf '%s\n' "$BACKING" >"$DIR/backing-before.txt"
/usr/bin/rm -f "$DIR/blockcommit-output.txt" "$DIR/blockcommit-error.txt"
STATE=$(/usr/bin/virsh -c qemu:///system domstate lab-vm 2>&1 || true)
if /usr/bin/test -z "$BACKING"; then
  /usr/bin/printf 'blockcommit unavailable: active image has no backing file\n' >"$DIR/blockcommit-error.txt"
elif ! /usr/bin/printf '%s\n' "$STATE" | /usr/bin/grep -Eqi 'running|работает'; then
  /usr/bin/printf 'blockcommit unavailable: domain is inactive\n' >"$DIR/blockcommit-error.txt"
elif /usr/bin/virsh -c qemu:///system blockcommit lab-vm vda --active --pivot --verbose >"$DIR/blockcommit-output.txt" 2>"$DIR/blockcommit-error.txt"; then
  /usr/bin/rm -f "$DIR/blockcommit-error.txt"
  /usr/bin/test -s "$DIR/blockcommit-output.txt" || /usr/bin/printf 'blockcommit completed and pivoted\n' >"$DIR/blockcommit-output.txt"
else
  /usr/bin/rm -f "$DIR/blockcommit-output.txt"
  /usr/bin/test -s "$DIR/blockcommit-error.txt" || /usr/bin/printf 'blockcommit operation failed\n' >"$DIR/blockcommit-error.txt"
fi
/usr/bin/virsh -c qemu:///system domblklist lab-vm --details >"$DIR/domblklist-after.txt"
AFTER=$(/usr/bin/awk '$3=="vda"{print $4; exit}' "$DIR/domblklist-after.txt")
/usr/bin/qemu-img info --backing-chain "$AFTER" >"$DIR/backing-chain-after.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
