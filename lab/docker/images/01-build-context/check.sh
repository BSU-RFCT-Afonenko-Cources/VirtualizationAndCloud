#!/usr/bin/env bash
set -euo pipefail

PROJECT=/home/ubuntu/image-lab
IGNORE="$PROJECT/.dockerignore"
for path in "$PROJECT/app.py" "$PROJECT/requirements.txt" "$PROJECT/VERSION" "$IGNORE"; do
  [[ -f "$path" ]] || { echo "Отсутствует $path"; exit 1; }
done

TMP=$(mktemp -d /tmp/image-context-check.XXXXXX)
IMAGE=image-lab-context-check:temporary
cleanup() {
  docker image rm -f "$IMAGE" >/dev/null 2>&1 || true
  rm -rf "$TMP"
}
trap cleanup EXIT
cat > "$TMP/Dockerfile" <<'DOCKERFILE'
FROM busybox:1.36
COPY . /context
DOCKERFILE

docker build --quiet --file "$TMP/Dockerfile" --tag "$IMAGE" "$PROJECT" >/dev/null
docker run --rm "$IMAGE" sh -c '
  test -f /context/app.py &&
  test -f /context/requirements.txt &&
  test -f /context/VERSION &&
  test ! -e /context/.env &&
  test ! -e /context/debug.log &&
  test ! -e /context/__pycache__
' || { echo "В build context попали запрещённые файлы или отсутствуют исходники"; exit 1; }
