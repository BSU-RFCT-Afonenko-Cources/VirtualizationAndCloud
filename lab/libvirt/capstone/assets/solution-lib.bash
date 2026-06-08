#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
ensure_dir(){ /usr/bin/sudo -n /usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$1"; }
ssh_vm(){ local ip="$1"; shift; /usr/bin/ssh -i /home/ubuntu/capstone/ssh/id_ed25519 -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=8 ubuntu@"$ip" "$@"; }
scp_vm(){ local src="$1" ip="$2" dst="$3"; /usr/bin/scp -i /home/ubuntu/capstone/ssh/id_ed25519 -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=8 "$src" ubuntu@"$ip":"$dst"; }
wait_ssh(){ local ip="$1"; for _ in $(/usr/bin/seq 1 60); do ssh_vm "$ip" true >/dev/null 2>&1 && return 0; /usr/bin/sleep 2; done; fail "SSH $ip недоступен"; }
wait_http(){ local url="$1"; for _ in $(/usr/bin/seq 1 60); do /usr/bin/curl -fsS --max-time 3 "$url" >/dev/null 2>&1 && return 0; /usr/bin/sleep 2; done; fail "HTTP endpoint $url недоступен"; }
