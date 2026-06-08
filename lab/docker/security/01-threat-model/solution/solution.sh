#!/bin/bash
set -euo pipefail
cat > /home/ubuntu/docker-security/threat-model.json <<'JSON'
{
  "service": "hardened-api",
  "risks": [
    {"category":"root-user","asset":"host and container processes","threat":"application compromise with UID 0","impact":"broader control over container resources","mitigation":"run the API as UID and GID 10001"},
    {"category":"writable-rootfs","asset":"application filesystem","threat":"runtime modification or persistence","impact":"tampered application state survives in the container layer","mitigation":"make rootfs read-only and isolate one temporary writable path"},
    {"category":"capabilities","asset":"shared Linux kernel","threat":"abuse of unnecessary kernel privileges","impact":"expanded actions after code execution","mitigation":"drop every capability and prevent privilege escalation"},
    {"category":"secret-in-image","asset":"database credential","threat":"credential recovery from image metadata or layers","impact":"unauthorized database access","mitigation":"mount the secret as a read-only runtime file"}
  ]
}
JSON
chown ubuntu:ubuntu /home/ubuntu/docker-security/threat-model.json
