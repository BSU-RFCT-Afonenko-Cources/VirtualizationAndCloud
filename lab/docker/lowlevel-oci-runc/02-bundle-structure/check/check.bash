#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../assets/oci-lab-lib.bash"
[[ -d "$ROOTFS" && -x "$ROOTFS/bin/sh" && -s "$BUNDLE/config.json" ]]
jq -e '.ociVersion and .root.path == "rootfs" and (.process.args | length > 0) and (.linux.namespaces | length > 0)' "$BUNDLE/config.json" >/dev/null
find "$ROOTFS" -mindepth 1 -print -quit | grep -q .
printf 'OK: %s\n' "02-bundle-structure"
