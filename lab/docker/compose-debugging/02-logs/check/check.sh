#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
for service in web api db; do
  file="$LAB/evidence/$service.log"
  test -s "$file" || { echo "Нет журнала $file"; exit 1; }
  if ! grep -Eq 'lab-logs-02|(/api/items.*(request|endpoint|SELECT)|request.*api/items)' "$file"; then
    echo "$file не содержит корреляционного маркера"
    exit 1
  fi
done
