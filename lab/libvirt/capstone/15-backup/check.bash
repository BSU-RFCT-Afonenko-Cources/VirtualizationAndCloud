#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
D=/home/ubuntu/capstone/15-backup/set
for f in cap-edge.xml cap-app.xml cap-db.xml cap-front.xml cap-back.xml capstone-pool.xml volumes.txt cap-db-data.qcow2 orders.json manifest.json SHA256SUMS; do need_file "$D/$f"; done
(cd "$D" && /usr/bin/sha256sum -c SHA256SUMS >/dev/null) || fail 'checksum backup не сходится'
/usr/bin/python3 -c 'import json;x=json.load(open("/home/ubuntu/capstone/15-backup/set/orders.json")); assert x["source"]=="cap-db" and any(o["id"]==1001 for o in x["orders"])' || fail 'orders.json не содержит данные базы'
