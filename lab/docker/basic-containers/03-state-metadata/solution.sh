#!/bin/bash
set -euo pipefail
/usr/bin/docker inspect lab-http > /home/ubuntu/basic-containers/evidence/03-inspect.json
/usr/bin/jq '.[0] | {name: .Name, image: .Config.Image, running: .State.Running, networks: (.NetworkSettings.Networks | keys), mounts: .Mounts}' /home/ubuntu/basic-containers/evidence/03-inspect.json > /home/ubuntu/basic-containers/evidence/03-summary.json
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/basic-containers/evidence/03-inspect.json /home/ubuntu/basic-containers/evidence/03-summary.json
