#!/usr/bin/env bash
set -euo pipefail
SOURCE=$(readlink -f "$(dirname "$0")/../assets/rootfs-labctl")
install -o root -g root -m 0755 "$SOURCE" /usr/local/sbin/rootfs-labctl
cat > /etc/sudoers.d/rootfs-lab <<'SUDOERS'
ubuntu ALL=(root) NOPASSWD: /usr/local/sbin/rootfs-labctl *
SUDOERS
chmod 0440 /etc/sudoers.d/rootfs-lab
/usr/local/sbin/rootfs-labctl init
