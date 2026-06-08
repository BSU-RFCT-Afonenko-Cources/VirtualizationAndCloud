#!/usr/bin/env bash
set -euo pipefail
E=/home/ubuntu/rootfs-lab/evidence
for f in docker-info.json docker-container-inspect.json docker-image-inspect.json docker-layers.json; do test -s "$E/$f" || { echo "Нет $f"; exit 1; }; done
python3 -c "import json; info=json.load(open('$E/docker-info.json')); summary=json.load(open('$E/docker-layers.json')); container=json.load(open('$E/docker-container-inspect.json'))[0]; assert info['driver'] and summary['container']=='rootfs-layer-evidence' and container['Name']=='/rootfs-layer-evidence' and 'GraphDriver' in container"
