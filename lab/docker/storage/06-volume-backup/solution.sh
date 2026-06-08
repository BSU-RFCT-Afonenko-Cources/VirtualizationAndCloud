#!/bin/bash
set -euo pipefail
/usr/bin/docker rm -f storage-backup >/dev/null 2>&1 || /usr/bin/true
/usr/bin/docker run --name storage-backup --label course.role=backup --mount type=volume,src=lab-data,dst=/data,readonly --mount type=bind,src=/home/ubuntu/storage/backups,dst=/backup alpine:3.20 /bin/sh -c '/bin/tar -czf /backup/lab-data.tar.gz -C /data records.json'
/usr/bin/sha256sum /home/ubuntu/storage/backups/lab-data.tar.gz > /home/ubuntu/storage/backups/lab-data.tar.gz.sha256
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/storage/backups/lab-data.tar.gz /home/ubuntu/storage/backups/lab-data.tar.gz.sha256
