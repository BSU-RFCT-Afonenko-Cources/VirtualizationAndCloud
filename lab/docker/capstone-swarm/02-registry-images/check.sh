#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
docker inspect market-registry >/dev/null 2>&1 || fail "Контейнер market-registry не найден"
[ "$(docker inspect --format '{{.State.Running}}' market-registry)" = true ] || fail "Registry не запущен"
for repo in market-edge market-orders market-catalog market-worker; do
  tags=$(curl -fsS "http://127.0.0.1:5000/v2/$repo/tags/list") || fail "Registry не возвращает $repo"
  jq -e '.tags | index("1.0")' <<<"$tags" >/dev/null || fail "Нет тега $repo:1.0"
  digest=$(curl -fsSI -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' "http://127.0.0.1:5000/v2/$repo/manifests/1.0" | tr -d '' | awk -F': ' 'tolower($1)=="docker-content-digest"{print $2}')
  [[ "$digest" == sha256:* ]] || fail "Нет digest для $repo:1.0"
done
echo "OK: custom images опубликованы в registry"
