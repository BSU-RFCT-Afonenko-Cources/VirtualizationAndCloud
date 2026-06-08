#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
for n in cap-front cap-back; do info=$(virsh net-info "$n") || fail "нет сети $n"; /usr/bin/grep -Eq 'Active:.*(yes|да)|Активн.*(yes|да)' <<<"$info" || fail "$n не активна"; /usr/bin/grep -Eq 'Autostart:.*(yes|да)|Автозапуск:.*(yes|да)' <<<"$info" || fail "$n без autostart"; need_file "/home/ubuntu/capstone/04-networks/$n.xml"; done
front=$(virsh net-dumpxml cap-front); back=$(virsh net-dumpxml cap-back)
/usr/bin/grep -q "bridge name='virbr-cap-front'" <<<"$front" || fail 'неверный frontend bridge'; /usr/bin/grep -q "mode='nat'" <<<"$front" || fail 'cap-front должна использовать NAT'
/usr/bin/grep -q "bridge name='virbr-cap-back'" <<<"$back" || fail 'неверный backend bridge'; ! /usr/bin/grep -q '<forward' <<<"$back" || fail 'cap-back должна быть isolated'
