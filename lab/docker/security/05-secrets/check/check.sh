#!/bin/bash
set -euo pipefail
CONTAINER=security-api
IMAGE=security-api:lab
SECRET_FILE=/home/ubuntu/docker-security/runtime/secret/db_password
[ -f "$SECRET_FILE" ] || { echo "Подготовленный секрет отсутствует"; exit 1; }
SECRET=$(cat "$SECRET_FILE")
MOUNT=$(docker inspect -f '{{range .Mounts}}{{if eq .Destination "/run/secrets/db_password"}}{{.Type}}|{{.Source}}|{{.RW}}{{end}}{{end}}' "$CONTAINER")
[ "$MOUNT" = "bind|$SECRET_FILE|false" ] || { echo "Секрет не подключён ожидаемым read-only bind mount"; exit 1; }
[ "$(docker exec "$CONTAINER" python -c "from pathlib import Path; print(bool(Path('/run/secrets/db_password').read_text().strip()))")" = True ] || { echo "Приложение не может прочитать секрет"; exit 1; }
for source in \
  "$(docker history --no-trunc "$IMAGE")" \
  "$(docker image inspect "$IMAGE")" \
  "$(docker inspect "$CONTAINER")" \
  "$(docker logs "$CONTAINER" 2>&1)"; do
  [[ "$source" != *"$SECRET"* ]] || { echo "Значение секрета обнаружено в метаданных или логах"; exit 1; }
done
RESULT=$(python3 -c "import json,urllib.request; print(json.load(urllib.request.urlopen('http://127.0.0.1:18080/api/status', timeout=3))['secret_loaded'])")
[ "$RESULT" = True ] || { echo "API не подтверждает загрузку секрета"; exit 1; }
echo "Секрет доступен только через runtime-файл и не раскрыт"
