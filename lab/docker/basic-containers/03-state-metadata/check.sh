#!/bin/bash
set -euo pipefail
/usr/bin/jq -e 'type == "array" and length == 1 and .[0].Name == "/lab-http" and .[0].State.Running == true and .[0].Config.Image == "lab-http-image:1.0" and (.[0].NetworkSettings.Networks | has("lab-net")) and (.[0].Mounts | type == "array")' /home/ubuntu/basic-containers/evidence/03-inspect.json >/dev/null
/usr/bin/jq -e '.name == "/lab-http" and .image == "lab-http-image:1.0" and .running == true and (.networks | index("lab-net")) != null and (.mounts | type == "array")' /home/ubuntu/basic-containers/evidence/03-summary.json >/dev/null
