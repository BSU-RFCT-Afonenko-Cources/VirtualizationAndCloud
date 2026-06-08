#!/bin/bash
set -euo pipefail
/usr/bin/docker info >/dev/null
/usr/bin/jq -e 'type == "object" and (.ServerVersion | type == "string")' /home/ubuntu/basic-containers/evidence/engine.json >/dev/null
/usr/bin/jq -e 'type == "array" and length > 0 and all(.[]; has("Id") and has("RepoTags"))' /home/ubuntu/basic-containers/evidence/images.json >/dev/null
/usr/bin/jq -e 'type == "array" and all(.[]; has("Id") and has("State") and has("Config"))' /home/ubuntu/basic-containers/evidence/containers.json >/dev/null
/usr/bin/jq -e 'type == "array" and length > 0 and all(.[]; has("Name") and has("Driver"))' /home/ubuntu/basic-containers/evidence/networks.json >/dev/null
