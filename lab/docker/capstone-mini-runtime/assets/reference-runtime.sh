#!/bin/bash
set -euo pipefail

LAB=/home/ubuntu/mini-runtime
ROOTFS=$LAB/rootfs
STATE=$LAB/runtime-state
EVIDENCE=$LAB/evidence
CGROUP=/sys/fs/cgroup/mini-runtime
RUN_DIR=/run/mini-runtime-lab
PID_FILE=$RUN_DIR/launcher.pid
API_PID_FILE=$RUN_DIR/api.pid
READY_FILE=$RUN_DIR/start
API_SOURCE=/usr/local/lib/mini-runtime-lab/mini-runtime-api.py

copy_binary() {
    local binary=$1 target
    if [[ "$binary" = /* ]]; then target=$binary; else target=$(command -v "$binary"); fi
    install -D -m 0755 "$target" "$ROOTFS$target"
    ldd "$target" 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i ~ /^\//) print $i}' | while read -r lib; do
        install -D -m 0755 "$lib" "$ROOTFS$lib"
    done
}

make_spec() {
    install -o ubuntu -g ubuntu -m 0644 /usr/local/lib/mini-runtime-lab/spec-template.yaml "$LAB/mini-runtime-spec.yaml"
}

make_rootfs() {
    rm -rf "$ROOTFS"
    install -d -o root -g root -m 0755 "$ROOTFS"/{bin,etc,proc,sys/fs/cgroup,run/mini-runtime,opt/mini-runtime,usr/bin,usr/lib,lib,lib64}
    for binary in /bin/sh /usr/bin/mount /bin/hostname /usr/bin/setpriv /usr/bin/python3; do copy_binary "$binary"; done
    local pyver
    pyver=$(/usr/bin/python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')
    cp -a "/usr/lib/$pyver" "$ROOTFS/usr/lib/"
    if [ -d "/usr/local/lib/$pyver" ]; then
        install -d "$ROOTFS/usr/local/lib"
        cp -a "/usr/local/lib/$pyver" "$ROOTFS/usr/local/lib/"
    fi
    printf 'root:x:0:0:root:/root:/bin/sh\nnobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin\n' > "$ROOTFS/etc/passwd"
    printf 'root:x:0:\nnogroup:x:65534:\n' > "$ROOTFS/etc/group"
    printf 'mini-runtime-rootfs-v1\n' > "$ROOTFS/.mini-runtime-rootfs"
    install -m 0755 "$API_SOURCE" "$ROOTFS/opt/mini-runtime/mini-runtime-api.py"
    chown -R root:root "$ROOTFS"
    chmod -R a-w "$ROOTFS"
    chmod 0555 "$ROOTFS" "$ROOTFS/proc" "$ROOTFS/sys" "$ROOTFS/sys/fs" "$ROOTFS/sys/fs/cgroup" "$ROOTFS/run" "$ROOTFS/run/mini-runtime"
    install -d -o 65534 -g 65534 -m 0750 "$STATE"
}

inner_command() {
    cat <<INNER
set -eu
mount --make-rprivate /
mount --bind '$ROOTFS' '$ROOTFS'
mount -o remount,bind,ro '$ROOTFS'
mount --bind '$STATE' '$ROOTFS/run/mini-runtime'
mount --rbind /sys/fs/cgroup '$ROOTFS/sys/fs/cgroup'
mount -o remount,bind,ro '$ROOTFS/sys/fs/cgroup'
mount -t proc proc '$ROOTFS/proc'
hostname mini-runtime
exec chroot '$ROOTFS' /usr/bin/setpriv --reuid=65534 --regid=65534 --clear-groups --bounding-set=-all --inh-caps=-all --ambient-caps=-all --no-new-privs /usr/bin/python3 -B /opt/mini-runtime/mini-runtime-api.py
INNER
}

find_api_pid() {
    local candidate
    for _ in $(seq 1 100); do
        while read -r candidate; do
            if [ -r "/proc/$candidate/status" ] && awk '/^NSpid:/ {exit !($NF == 1)}' "/proc/$candidate/status"; then
                printf '%s\n' "$candidate"
                return 0
            fi
        done < <(pgrep -P "$(cat "$PID_FILE")" -a 2>/dev/null | awk '{print $1}')
        candidate=$(pgrep -f '/opt/mini-runtime/mini-runtime-api.py' | tail -n1 || true)
        if [ -n "$candidate" ] && awk '/^NSpid:/ {exit !($NF == 1)}' "/proc/$candidate/status" 2>/dev/null; then
            printf '%s\n' "$candidate"
            return 0
        fi
        sleep 0.1
    done
    return 1
}

start_runtime() {
    stop_runtime || true
    install -d -m 0755 "$RUN_DIR"
    rm -f "$READY_FILE"
    mkdir -p "$CGROUP"
    printf '134217728\n' > "$CGROUP/memory.max"
    printf '64\n' > "$CGROUP/pids.max"
    printf '50000 100000\n' > "$CGROUP/cpu.max"
    local inner quoted
    inner=$(inner_command)
    printf -v quoted '%q' "$inner"
    bash -c "while [ ! -e '$READY_FILE' ]; do sleep 0.05; done; exec unshare --fork --pid --uts --mount --net /bin/sh -c $quoted" \
        >>"$STATE/launcher.log" 2>&1 &
    local launcher=$!
    printf '%s\n' "$launcher" > "$PID_FILE"
    printf '%s\n' "$launcher" > "$CGROUP/cgroup.procs"
    touch "$READY_FILE"
    local api_pid
    api_pid=$(find_api_pid)
    printf '%s\n' "$api_pid" > "$API_PID_FILE"

    ip link del mrt-host 2>/dev/null || true
    ip link add mrt-host type veth peer name mrt-runtime
    ip link set mrt-runtime netns "$api_pid"
    ip address add 10.200.0.1/30 dev mrt-host
    ip link set mrt-host up
    nsenter -t "$api_pid" -n ip link set lo up
    nsenter -t "$api_pid" -n ip address add 10.200.0.2/30 dev mrt-runtime
    nsenter -t "$api_pid" -n ip link set mrt-runtime up

    for _ in $(seq 1 50); do
        curl --noproxy '*' --silent --fail --max-time 1 http://10.200.0.2:8080/status >/dev/null && return 0
        sleep 0.1
    done
    return 1
}

stop_runtime() {
    ip link del mrt-host 2>/dev/null || true
    if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null || true
        sleep 0.3
        kill -KILL "$(cat "$PID_FILE")" 2>/dev/null || true
    fi
    if [ -d "$CGROUP" ]; then
        if [ -w "$CGROUP/cgroup.kill" ]; then
            printf '1\n' > "$CGROUP/cgroup.kill" 2>/dev/null || true
        fi
        for _ in $(seq 1 50); do
            [ ! -s "$CGROUP/cgroup.procs" ] && break
            while read -r pid; do kill -KILL "$pid" 2>/dev/null || true; done < "$CGROUP/cgroup.procs"
            sleep 0.05
        done
        rmdir "$CGROUP" 2>/dev/null || true
    fi
    rm -rf "$RUN_DIR"
}

collect_evidence() {
    local pid
    pid=$(cat "$API_PID_FILE")
    install -d -o ubuntu -g ubuntu -m 0755 "$EVIDENCE"
    python3 - "$pid" "$EVIDENCE" <<'PY'
import json, os, pathlib, subprocess, sys
pid, out = sys.argv[1], pathlib.Path(sys.argv[2])
def text(path): return pathlib.Path(path).read_text().strip()
def command(*args): return subprocess.check_output(args, text=True).strip()
namespaces = {name: os.readlink(f"/proc/{pid}/ns/{name}") for name in ("uts", "pid", "mnt", "net")}
status = text(f"/proc/{pid}/status")
status_fields = {line.split(":", 1)[0]: line.split(":", 1)[1].strip() for line in status.splitlines() if ":" in line}
(out / "runtime.json").write_text(json.dumps({"pid": int(pid), "hostname": command("nsenter", "-t", pid, "-u", "hostname"), "namespaces": namespaces, "cgroup": text(f"/proc/{pid}/cgroup")}, indent=2) + "\n")
(out / "resources.json").write_text(json.dumps({name: text(f"/sys/fs/cgroup/mini-runtime/{name}") for name in ("memory.max", "pids.max", "cpu.max")}, indent=2) + "\n")
(out / "privileges.json").write_text(json.dumps({key: status_fields.get(key) for key in ("Uid", "Gid", "CapEff", "CapBnd", "NoNewPrivs", "Seccomp")}, indent=2) + "\n")
(out / "network.json").write_text(json.dumps({"endpoint": "http://10.200.0.2:8080/status", "interfaces": json.loads(command("nsenter", "-t", pid, "-n", "ip", "-j", "address", "show"))}, indent=2) + "\n")
(out / "mounts.txt").write_text(text(f"/proc/{pid}/mountinfo") + "\n")
PY
    curl --noproxy '*' --silent --fail http://10.200.0.2:8080/status > "$EVIDENCE/api.json"
    chown -R ubuntu:ubuntu "$EVIDENCE"
}

failure_drill() {
    local old_pid new_pid
    old_pid=$(cat "$API_PID_FILE")
    stop_runtime
    [ ! -e "/proc/$old_pid" ]
    [ ! -e "$CGROUP" ]
    [ ! -e /sys/class/net/mrt-host ]
    start_runtime
    new_pid=$(cat "$API_PID_FILE")
    python3 - "$old_pid" "$new_pid" "$EVIDENCE/restart.json" <<'PY'
import json, pathlib, sys
old_pid, new_pid, path = sys.argv[1:]
pathlib.Path(path).write_text(json.dumps({"old_pid": int(old_pid), "new_pid": int(new_pid), "cleanup_verified": True, "restart_verified": old_pid != new_pid}, indent=2) + "\n")
PY
    chown ubuntu:ubuntu "$EVIDENCE/restart.json"
}

case "${1:-all}" in
    spec) make_spec ;;
    rootfs) make_rootfs ;;
    start) start_runtime ;;
    stop) stop_runtime ;;
    evidence) collect_evidence ;;
    failure) failure_drill ;;
    all) make_spec; make_rootfs; start_runtime; collect_evidence; failure_drill; collect_evidence ;;
    *) echo "unknown action: $1" >&2; exit 2 ;;
esac
