#!/bin/bash
set -euo pipefail

catalog=$(/usr/bin/curl --fail --silent http://127.0.0.1:5000/v2/_catalog)
tags=$(/usr/bin/curl --fail --silent http://127.0.0.1:5000/v2/course/api/tags/list)
/usr/bin/jq -e '.repositories | index("course/api") != null' <<<"$catalog" >/dev/null || { echo "Repository course/api отсутствует в catalog"; exit 1; }
/usr/bin/jq -e '.tags | index("v1") != null' <<<"$tags" >/dev/null || { echo "Tag v1 отсутствует в registry"; exit 1; }
digest=$(/usr/bin/curl --fail --silent --head --header 'Accept: application/vnd.docker.distribution.manifest.v2+json' http://127.0.0.1:5000/v2/course/api/manifests/v1 | /usr/bin/awk -F': ' 'tolower($1)=="docker-content-digest" {gsub("\r", "", $2); print $2}')
[[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]] || { echo "Registry не вернул корректный digest manifest v1"; exit 1; }
