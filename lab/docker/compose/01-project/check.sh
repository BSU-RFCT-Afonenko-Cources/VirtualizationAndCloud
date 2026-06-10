#!/usr/bin/env bash
set -euo pipefail
base=/home/ubuntu/compose-lab
for path in "$base/compose.yaml" "$base/api/app.py" "$base/api/Dockerfile" "$base/api/version.txt" "$base/web/default.conf.template"; do
  test -f "$path" || { echo "Отсутствует $path"; exit 1; }
done
for path in "$base/api" "$base/web"; do test -d "$path" || exit 1; done
test ! -s "$base/compose.yaml" || { echo "На первом шаге compose.yaml должен быть пустым"; exit 1; }
if find "$base" -type f \( -name '.env' -o -name '*.pem' -o -name '*.key' -o -name 'id_rsa*' \) -print -quit | grep -q .; then echo "В проекте найден потенциальный секрет"; exit 1; fi
cmp -s "$base/api/app.py" /home/ubuntu/compose-lab/starter/api/app.py
cmp -s "$base/api/Dockerfile" /home/ubuntu/compose-lab/starter/api/Dockerfile
cmp -s "$base/web/default.conf.template" /home/ubuntu/compose-lab/starter/web/default.conf.template
echo "Структура проекта корректна"
