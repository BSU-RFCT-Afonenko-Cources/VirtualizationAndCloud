#!/bin/bash
set -euo pipefail
/usr/bin/docker image inspect python:3.12-alpine >/dev/null 2>&1 || /usr/bin/docker pull python:3.12-alpine
/usr/bin/test -f /home/ubuntu/storage/backups/lab-data.tar.gz
/usr/bin/test -f /home/ubuntu/storage/backups/lab-data.tar.gz.sha256
/usr/bin/docker rm -f storage-restore storage-api-restore >/dev/null 2>&1 || /usr/bin/true
/usr/bin/docker volume rm lab-data-restore >/dev/null 2>&1 || /usr/bin/true
