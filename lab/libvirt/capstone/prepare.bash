#!/usr/bin/env bash
set -euo pipefail
BASE=/home/ubuntu/capstone
SOURCE=$(/usr/bin/realpath "$0")
SOURCE_DIR=$(/usr/bin/dirname "$SOURCE")
/usr/bin/sudo -n /usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$BASE" "$BASE/assets" "$BASE/ssh"
/usr/bin/sudo -n /usr/bin/cp -a "$SOURCE_DIR/assets/." "$BASE/assets/"
/usr/bin/sudo -n /usr/bin/chown -R ubuntu:ubuntu "$BASE"
if ! /usr/bin/test -s "$BASE/ssh/id_ed25519"; then
 /usr/bin/sudo -n -u ubuntu /usr/bin/ssh-keygen -q -t ed25519 -N '' -f "$BASE/ssh/id_ed25519"
fi
