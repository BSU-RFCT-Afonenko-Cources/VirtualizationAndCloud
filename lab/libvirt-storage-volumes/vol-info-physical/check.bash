#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-info-physical
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in sparse-info-bytes.txt sparse-info-physical.txt raw-info-bytes.txt raw-info-physical.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
/usr/bin/grep -Eq 'Capacity:[[:space:]]+[0-9]+' "$DIR/sparse-info-bytes.txt" || fail "sparse-info-bytes.txt должен содержать Capacity в байтах"
/usr/bin/grep -Eq 'Allocation:[[:space:]]+[0-9]+' "$DIR/sparse-info-bytes.txt" || fail "sparse-info-bytes.txt должен содержать Allocation в байтах"
/usr/bin/grep -Eq 'Capacity:[[:space:]]+[0-9]+' "$DIR/raw-info-bytes.txt" || fail "raw-info-bytes.txt должен содержать Capacity в байтах"
if ! /usr/bin/grep -Eq '(Physical|Allocation|Capacity|not supported|unsupported|error|failed)' "$DIR/sparse-info-physical.txt"; then fail "sparse-info-physical.txt должен содержать physical/allocation или понятную ошибку backend"; fi
if ! /usr/bin/grep -Eq '(Physical|Allocation|Capacity|not supported|unsupported|error|failed)' "$DIR/raw-info-physical.txt"; then fail "raw-info-physical.txt должен содержать physical/allocation или понятную ошибку backend"; fi
