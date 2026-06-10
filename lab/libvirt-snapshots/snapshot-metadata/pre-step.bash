#!/usr/bin/env bash
set -euo pipefail
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 /home/ubuntu/snapshot-metadata
/usr/bin/install -d -o root -g root -m 1777 /home/ubuntu/snapshot-metadata/libvirt-snapshots
