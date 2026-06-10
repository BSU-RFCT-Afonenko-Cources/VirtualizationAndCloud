#!/usr/bin/env bash
set -euo pipefail

LAB_HOME=/home/ubuntu/oci-runc-lab
BUNDLE=/home/ubuntu/oci-runc-lab/oci-lab-bundle
ROOTFS=/home/ubuntu/oci-runc-lab/oci-lab-bundle/rootfs
EVIDENCE=/home/ubuntu/oci-runc-lab/evidence
SHARED=/home/ubuntu/oci-runc-lab/shared
RUNC_ROOT=/run/oci-lowlevel-runc
CONTAINER_ID=oci-lowlevel-lab
DOCKER_NAME=oci-lowlevel-docker

ensure_layout() {
  install -d -m 0755 -o ubuntu -g ubuntu "$LAB_HOME" "$BUNDLE" "$ROOTFS" "$EVIDENCE" "$SHARED"
  install -d -m 0755 "$RUNC_ROOT"
}

runtime_bin() {
  if command -v runc >/dev/null 2>&1; then command -v runc; return; fi
  if command -v crun >/dev/null 2>&1; then command -v crun; return; fi
  return 1
}

runc_cmd() {
  local runtime
  runtime="$(runtime_bin)"
  "$runtime" --root "$RUNC_ROOT" "$@"
}

container_status() {
  runc_cmd state "$CONTAINER_ID" 2>/dev/null | jq -r '.status' 2>/dev/null || true
}

container_pid() {
  runc_cmd state "$CONTAINER_ID" 2>/dev/null | jq -r '.pid // empty' 2>/dev/null || true
}

remove_container() {
  runc_cmd kill "$CONTAINER_ID" KILL >/dev/null 2>&1 || true
  sleep 0.2
  runc_cmd delete --force "$CONTAINER_ID" >/dev/null 2>&1 || true
}

build_rootfs() {
  ensure_layout
  rm -rf "$ROOTFS"
  install -d -m 0755 "$ROOTFS"/{bin,dev,dev/pts,dev/shm,etc,proc,sys,tmp,run,opt,data,home,home/ubuntu,home/ubuntu/oci-runc-lab}
  local busybox
  busybox="$(command -v busybox)"
  cp "$busybox" "$ROOTFS/bin/busybox"
  chmod 0755 "$ROOTFS/bin/busybox"
  local applet
  for applet in sh sleep date mkdir cat hostname mount ps nc uname id; do
    ln -sf busybox "$ROOTFS/bin/$applet"
  done
  cat > "$ROOTFS/home/ubuntu/oci-runc-lab/workload.sh" <<'WORKLOAD'
#!/bin/sh
set -eu
mkdir -p /run/oci-lab /data
heartbeat() {
  while :; do
    date +%s > /run/oci-lab/heartbeat
    sleep 1
  done
}
serve() {
  while :; do
    printf 'HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nOCI workload is alive\n' | nc -l -p 8080 || true
  done
}
heartbeat &
serve &
wait
WORKLOAD
  chmod 0755 "$ROOTFS/home/ubuntu/oci-runc-lab/workload.sh"
  printf 'shared OCI bind mount\n' > "$SHARED/source.txt"
  chown -R ubuntu:ubuntu "$LAB_HOME"
}

write_config() {
  local stage="${1:-full}"
  ensure_layout
  local mounts='[
    {"destination":"/proc","type":"proc","source":"proc"},
    {"destination":"/dev","type":"tmpfs","source":"tmpfs","options":["nosuid","strictatime","mode=755","size=65536k"]},
    {"destination":"/home/ubuntu/oci-runc-lab/tmp","type":"tmpfs","source":"tmpfs","options":["nosuid","nodev","mode=1777","size=16m"]},
    {"destination":"/data","type":"bind","source":"/home/ubuntu/oci-runc-lab/shared","options":["rbind","rw"]}
  ]'
  local namespaces='[
    {"type":"pid"},{"type":"ipc"},{"type":"uts"},{"type":"mount"}
  ]'
  local resources='{}'
  local seccomp='null'
  local caps='["CAP_CHOWN","CAP_DAC_OVERRIDE","CAP_FOWNER","CAP_KILL","CAP_SETGID","CAP_SETUID","CAP_NET_BIND_SERVICE"]'

  if [[ "$stage" == "bundle" || "$stage" == "process" ]]; then
    mounts='[{"destination":"/proc","type":"proc","source":"proc"},{"destination":"/dev","type":"tmpfs","source":"tmpfs","options":["nosuid","mode=755","size=65536k"]}]'
  fi
  if [[ "$stage" == "bundle" ]]; then
    namespaces='[{"type":"mount"}]'
  fi
  if [[ "$stage" == "mounts" ]]; then
    namespaces='[{"type":"mount"}]'
  fi
  if [[ "$stage" == "cgroups" || "$stage" == "security" || "$stage" == "full" ]]; then
    resources='{"memory":{"limit":134217728},"cpu":{"quota":50000,"period":100000}}'
  fi
  if [[ "$stage" == "security" || "$stage" == "full" ]]; then
    seccomp='{"defaultAction":"SCMP_ACT_ALLOW","architectures":["SCMP_ARCH_X86_64","SCMP_ARCH_X86","SCMP_ARCH_X32"],"syscalls":[{"names":["keyctl","add_key","request_key"],"action":"SCMP_ACT_ERRNO","errnoRet":1}]}'
  fi

  jq -n \
    --argjson mounts "$mounts" \
    --argjson namespaces "$namespaces" \
    --argjson resources "$resources" \
    --argjson seccomp "$seccomp" \
    --argjson caps "$caps" '
    {
      ociVersion:"1.0.2",
      process:{
        terminal:false,
        user:{uid:0,gid:0},
        args:["/bin/sh","/home/ubuntu/oci-runc-lab/workload.sh"],
        env:["PATH=/bin","HOSTNAME=oci-lowlevel","OCI_LAB=1"],
        cwd:"/",
        capabilities:{bounding:$caps,effective:$caps,inheritable:[],permitted:$caps,ambient:[]},
        noNewPrivileges:true
      },
      root:{path:"rootfs",readonly:false},
      hostname:"oci-lowlevel",
      mounts:$mounts,
      linux:({namespaces:$namespaces,resources:$resources,devices:[
        {path:"/dev/null",type:"c",major:1,minor:3,fileMode:438,uid:0,gid:0},
        {path:"/dev/zero",type:"c",major:1,minor:5,fileMode:438,uid:0,gid:0},
        {path:"/dev/random",type:"c",major:1,minor:8,fileMode:438,uid:0,gid:0},
        {path:"/dev/urandom",type:"c",major:1,minor:9,fileMode:438,uid:0,gid:0}
      ]} + (if $seccomp == null then {} else {seccomp:$seccomp} end))
    }' > "$BUNDLE/config.json"
  chown ubuntu:ubuntu "$BUNDLE/config.json"
}

start_container() {
  remove_container
  runc_cmd run --detach --bundle "$BUNDLE" "$CONTAINER_ID"
}

wait_for_heartbeat() {
  local pid i
  for i in $(seq 1 30); do
    pid="$(container_pid)"
    if [[ -n "$pid" && -s "/proc/$pid/root/run/oci-lab/heartbeat" ]]; then return 0; fi
    sleep 0.2
  done
  return 1
}

save_runtime_state() {
  runc_cmd state "$CONTAINER_ID" > "$EVIDENCE/runc-state.json"
  chown ubuntu:ubuntu "$EVIDENCE/runc-state.json"
}
