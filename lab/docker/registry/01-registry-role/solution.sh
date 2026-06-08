#!/bin/bash
set -euo pipefail

/usr/bin/docker rm --force lab-registry >/dev/null 2>&1 || true
/usr/bin/docker run --detach --name lab-registry --restart unless-stopped --publish 5000:5000 registry:2
