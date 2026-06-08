#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/lowlevel-security-primitives
SRC=/workspace/VirtualizationAndCloud/lab/docker/lowlevel-security-primitives/assets
install -d -m 0755 -o ubuntu -g ubuntu "$LAB" "$LAB/evidence" "$LAB/runtime" "$LAB/profiles"
install -m 0644 -o ubuntu -g ubuntu "$SRC/seccomp-deny-uname.json" "$LAB/profiles/seccomp-deny-uname.json"
if ! command -v docker >/dev/null 2>&1; then
  printf '%s\n' 'Docker CLI is required for this laboratory' >&2
  exit 1
fi
if ! docker image inspect sec-demo:lab >/dev/null 2>&1; then
  docker build -t sec-demo:lab -f "$SRC/Dockerfile" "$SRC"
fi
for name in lsp-baseline lsp-cap-default lsp-cap-minimal lsp-sysadmin lsp-userns lsp-seccomp-default lsp-seccomp-custom lsp-nnp-off lsp-nnp-on lsp-readonly lsp-privileged lsp-hardened; do
  docker rm -f "$name" >/dev/null 2>&1 || true
done
chown -R ubuntu:ubuntu "$LAB"
