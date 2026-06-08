#!/bin/bash
set -euo pipefail

/usr/bin/docker tag course-registry-api:build-v1 localhost:5000/course/api:v1
