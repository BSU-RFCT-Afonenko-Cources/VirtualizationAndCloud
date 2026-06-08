#!/usr/bin/env bash
set -euo pipefail
EVIDENCE=/home/ubuntu/swarm-basic/lab-api-inspect.json
[ -s "$EVIDENCE" ] || { echo 'lab-api-inspect.json is missing or empty'; exit 1; }
jq -e '
  type == "array" and length == 1 and
  .[0].Spec.Name == "lab-api" and
  .[0].Spec.Mode.Replicated.Replicas == 3 and
  (.[0].Spec.TaskTemplate.ContainerSpec.Image | startswith("swarm-api:lab")) and
  any(.[0].Endpoint.Ports[]?;
    .PublishedPort == 8080 and .TargetPort == 8000 and .Protocol == "tcp" and .PublishMode == "ingress")
' "$EVIDENCE" >/dev/null || { echo 'Evidence does not contain the required Spec, Mode, and Endpoint state'; exit 1; }
live_id="$(docker service inspect --format '{{.ID}}' lab-api 2>/dev/null)"
file_id="$(jq -r '.[0].ID' "$EVIDENCE")"
[ "$file_id" = "$live_id" ] || { echo 'Evidence does not describe the current lab-api service'; exit 1; }
echo 'Inspect evidence contains the current service Spec, replicated Mode, and Endpoint.'
