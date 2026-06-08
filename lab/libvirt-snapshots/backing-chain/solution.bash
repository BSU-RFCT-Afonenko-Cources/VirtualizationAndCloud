#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backing-chain
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/virsh -c qemu:///system domblklist lab-vm --details >"$DIR/domblklist.txt"
ACTIVE=$(/usr/bin/awk '$3=="vda"{print $4; exit}' "$DIR/domblklist.txt")
/usr/bin/printf 'ACTIVE_DISK=%s\n' "$ACTIVE" >"$DIR/active-disk.env"
/usr/bin/qemu-img info --backing-chain "$ACTIVE" >"$DIR/backing-chain.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
