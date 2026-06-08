#!/bin/bash
set -euo pipefail
ROOT=$(/usr/bin/realpath "$(/usr/bin/dirname "$0")/..")
LAB=/home/ubuntu/cr-lab
SRC=/home/ubuntu/cr-lab/src
BIN=/home/ubuntu/cr-lab/bin
STATE=/home/ubuntu/cr-lab/state
EVIDENCE=/home/ubuntu/cr-lab/evidence
CHECKPOINTS=/home/ubuntu/cr-lab/checkpoints
LIB=/home/ubuntu/cr-lab/lib

/usr/bin/install -d -o ubuntu -g ubuntu "$SRC" "$BIN" "$STATE" "$EVIDENCE" "$CHECKPOINTS" "$LIB"
/usr/bin/install -m 0644 "$ROOT/assets/cr-demo-counter.c" "$SRC/cr-demo-counter.c"
/usr/bin/install -m 0644 "$ROOT/assets/Dockerfile" "$SRC/Dockerfile"
/usr/bin/install -m 0755 "$ROOT/lib/common.sh" "$LIB/common.sh"
if command -v gcc >/dev/null 2>&1; then
  if /usr/bin/gcc -O2 -static -o "$BIN/cr-demo-counter" "$SRC/cr-demo-counter.c" 2>"$EVIDENCE/build-static.log"; then
    /bin/chmod 0755 "$BIN/cr-demo-counter"
    /usr/bin/touch "$BIN/.static"
  else
    /usr/bin/gcc -O2 -o "$BIN/cr-demo-counter" "$SRC/cr-demo-counter.c" 2>"$EVIDENCE/build-dynamic.log"
    /bin/chmod 0755 "$BIN/cr-demo-counter"
  fi
fi
/bin/chown -R ubuntu:ubuntu "$LAB"
