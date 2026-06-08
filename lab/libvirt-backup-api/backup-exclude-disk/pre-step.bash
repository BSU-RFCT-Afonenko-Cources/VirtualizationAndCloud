#!/usr/bin/env bash
set -euo pipefail
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 /home/ubuntu/backup-exclude-disk
/usr/bin/install -d -m 0777 /tmp/libvirt-backups
