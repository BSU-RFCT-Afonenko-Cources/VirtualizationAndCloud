#!/usr/bin/env bash
set -euo pipefail
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 /home/ubuntu/checkpoint-create
/usr/bin/install -d -m 0777 /home/ubuntu/checkpoint-create/libvirt-backups
