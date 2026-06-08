#!/bin/bash
set -euo pipefail
/usr/bin/docker exec lab-http /bin/sh -c 'printf %s writable-layer-ok > /tmp/lab-control.txt'
/usr/bin/docker exec lab-http /bin/cat /tmp/lab-control.txt > /home/ubuntu/basic-containers/evidence/05-control.txt
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/basic-containers/evidence/05-control.txt
