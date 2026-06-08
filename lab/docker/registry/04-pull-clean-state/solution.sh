#!/bin/bash
set -euo pipefail

/usr/bin/docker image rm localhost:5000/course/api:v1 >/dev/null
/usr/bin/docker pull localhost:5000/course/api:v1
