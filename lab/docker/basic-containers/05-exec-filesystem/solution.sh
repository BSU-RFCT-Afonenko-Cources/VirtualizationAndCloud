#!/bin/bash
set -euo pipefail
/usr/bin/docker exec lab-http /bin/sh -c 'mkdir -p /home/ubuntu/basic-containers && printf %s writable-layer-ok > /home/ubuntu/basic-containers/lab-control.txt'
/usr/bin/docker exec lab-http /bin/cat /home/ubuntu/basic-containers/lab-control.txt > /home/ubuntu/basic-containers/evidence/05-control.txt
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/basic-containers/evidence/05-control.txt
