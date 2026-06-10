#!/usr/bin/env bash
set -euo pipefail
VM=lab-vm
DIR=/home/ubuntu/backup-cleanup
BACKUPDIR=/home/ubuntu/backup-cleanup/libvirt-backups
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/install -d -m 0777 "$BACKUPDIR"
while IFS= read -r CHECKPOINT; do
  case "$CHECKPOINT" in
    lab-*)
      /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system checkpoint-delete "$VM" "$CHECKPOINT" --metadata >>"$DIR/cleanup.txt" 2>&1 || /usr/bin/printf 'failed to delete %s metadata\n' "$CHECKPOINT" >>"$DIR/cleanup.txt"
      ;;
  esac
done < <(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system checkpoint-list "$VM" --name --topological 2>/dev/null | /usr/bin/tac)
/usr/bin/test -s "$DIR/cleanup.txt" || /usr/bin/printf 'no lab-prefixed checkpoints found\n' >"$DIR/cleanup.txt"
/usr/bin/find "$BACKUPDIR" -mindepth 1 -maxdepth 1 -type f -delete
/usr/bin/find "$BACKUPDIR" -mindepth 1 -maxdepth 1 -type s -delete
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system checkpoint-list "$VM" >"$DIR/checkpoint-list.txt" 2>&1 || /usr/bin/printf 'checkpoint-list unavailable\n' >"$DIR/checkpoint-list.txt"
/usr/bin/find "$BACKUPDIR" -mindepth 1 -maxdepth 1 -printf '%f\n' >"$DIR/backup-files.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system list --all >"$DIR/domain-list.txt" 2>&1 || /usr/bin/printf 'domain list unavailable\n' >"$DIR/domain-list.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR" "$BACKUPDIR"
