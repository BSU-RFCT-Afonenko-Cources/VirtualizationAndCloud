#!/usr/bin/env bash
set -euo pipefail
B=/home/ubuntu/rootfs-lab/rootfs-lab-base
E=/home/ubuntu/rootfs-lab/evidence
for d in bin etc proc sys dev tmp run var/www opt/config opt/data; do test -d "$B/$d" || { echo "Нет каталога $B/$d"; exit 1; }; done
test -x "$B/bin/busybox" || { echo "Нет исполняемого BusyBox"; exit 1; }
test -L "$B/bin/sh" || { echo "Нет applet-ссылки /bin/sh"; exit 1; }
test "$(stat -c %a "$B/tmp")" = "1777" || { echo "Неверные права /tmp"; exit 1; }
grep -q 'base-layer: original' "$B/var/www/index.html" || { echo "Нет контрольного HTTP-файла base layer"; exit 1; }
grep -q './var/www/index.html' "$E/base-inventory.txt" || { echo "Inventory не содержит HTTP-файл"; exit 1; }
test -s "$E/base-index.sha256" || { echo "Нет checksum base-файла"; exit 1; }
