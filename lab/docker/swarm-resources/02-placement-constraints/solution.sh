#!/usr/bin/env bash
set -euo pipefail
if docker service inspect lab-api >/dev/null 2>&1; then docker service rm lab-api >/dev/null; fi
docker service create --quiet --name lab-api --constraint 'node.labels.swarm_resources == true' --replicas 1 --publish published=18080,target=8080,mode=ingress swarm-resources-api:lab >/dev/null
