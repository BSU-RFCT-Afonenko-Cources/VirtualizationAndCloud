#!/bin/bash
set -euo pipefail
pass() { /usr/bin/printf 'PASS: %s\n' "$1"; }
fail() { /usr/bin/printf 'FAIL: %s\n' "$1" >&2; exit 1; }
require_file() { [[ -f "$1" ]] || fail "нет файла $1"; }
require_json() { require_file "$1"; /usr/bin/jq -e . "$1" >/dev/null || fail "некорректный JSON: $1"; }
require_feature() {
  local status; status=$(feature_status "$1")
  [[ "$status" == supported ]] || fail "feature $1 недоступна в этой VM; см. /home/ubuntu/ns-lab/capabilities.json"
}
feature_status() { /usr/bin/jq -r --arg key "$1" '.features[$key].status // "unknown"' /home/ubuntu/ns-lab/capabilities.json 2>/dev/null || /usr/bin/printf unknown; }
live_pid_file() { require_file "$1"; local p; p=$(/usr/bin/cat "$1"); [[ "$p" =~ ^[0-9]+$ && -d "/proc/$p" ]] || fail "процесс из $1 не существует"; /usr/bin/printf '%s' "$p"; }
