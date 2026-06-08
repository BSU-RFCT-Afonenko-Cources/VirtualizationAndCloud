#!/bin/bash
set -euo pipefail
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 /home/ubuntu/storage/backups
/usr/bin/docker volume inspect lab-data >/dev/null
/usr/bin/docker rm -f storage-backup >/dev/null 2>&1 || /usr/bin/true
/usr/bin/rm -f /home/ubuntu/storage/backups/lab-data.tar.gz /home/ubuntu/storage/backups/lab-data.tar.gz.sha256
