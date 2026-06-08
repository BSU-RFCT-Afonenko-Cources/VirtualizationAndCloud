#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/ns-lab
LIB=/usr/local/lib/ns-lab
SCRIPT_DIR=$(/usr/bin/dirname "$(/usr/bin/readlink -f "${BASH_SOURCE[0]}")")
missing=()
for command in /usr/bin/unshare /usr/bin/nsenter /usr/sbin/ip /usr/bin/ps /usr/bin/jq /usr/bin/python3 /usr/bin/curl /usr/bin/setpriv /usr/bin/mountpoint /usr/bin/ipcmk /usr/bin/ipcs /usr/bin/docker; do
  [[ -x "$command" ]] || missing+=("$command")
done
if ((${#missing[@]})); then
  /usr/bin/printf 'Не установлены обязательные компоненты util-linux, iproute2, procps, jq, python3 или Docker CLI: %s\n' "${missing[*]}" >&2
  exit 1
fi
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$LAB" "$LAB/evidence" "$LAB/state" "$LAB/mnt/private"
/usr/bin/install -d -o root -g root -m 0755 "$LIB"
/usr/bin/install -o root -g root -m 0755 "$SCRIPT_DIR/assets/ns-demo" "$LIB/ns-demo"
/usr/bin/install -o root -g root -m 0755 "$SCRIPT_DIR/assets/ns-http" "$LIB/ns-http"
/usr/bin/install -o root -g root -m 0644 "$SCRIPT_DIR/assets/check-common.bash" "$LIB/check-common.bash"

probe() {
  local name="$1"; shift
  local err="/tmp/ns-lab-probe-${name}.err"
  if "$@" 2>"$err"; then
    /usr/bin/jq -n --arg status supported '{status:$status}'
  else
    /usr/bin/jq -n --arg status unavailable --arg reason "$(/usr/bin/tr '\n' ' ' < "$err")" '{status:$status,reason:$reason}'
  fi
  /usr/bin/rm -f "$err"
}
uts=$(probe uts /usr/bin/unshare --uts /bin/true)
pid=$(probe pid /usr/bin/unshare --pid --fork /bin/true)
mount=$(probe mount /usr/bin/unshare --mount /bin/true)
ipc=$(probe ipc /usr/bin/unshare --ipc /bin/true)
net=$(probe network /usr/bin/unshare --net /bin/true)
user=$(probe user /usr/bin/setpriv --reuid=ubuntu --regid=ubuntu --init-groups /usr/bin/unshare --user --map-root-user /bin/true)
cgroup=$(probe cgroup /usr/bin/unshare --cgroup /bin/true)
time=$(if [[ -e /proc/self/ns/time ]]; then /usr/bin/jq -n '{status:"supported"}'; else /usr/bin/jq -n '{status:"unavailable",reason:"/proc/self/ns/time отсутствует"}'; fi)
docker_status=$(if /usr/bin/docker info >/dev/null 2>&1; then /usr/bin/jq -n '{status:"supported"}'; else /usr/bin/jq -n '{status:"unavailable",reason:"Docker daemon недоступен"}'; fi)
/usr/bin/jq -n --argjson uts "$uts" --argjson pid "$pid" --argjson mount "$mount" --argjson ipc "$ipc" --argjson network "$net" --argjson user "$user" --argjson cgroup "$cgroup" --argjson time "$time" --argjson docker "$docker_status" '{features:{uts:$uts,pid:$pid,mount:$mount,ipc:$ipc,network:$network,user:$user,cgroup:$cgroup,time:$time,docker:$docker}}' > "$LAB/capabilities.json"
/usr/bin/chown -R ubuntu:ubuntu "$LAB"
/usr/bin/printf 'Проверка namespace-возможностей завершена: %s\n' "$LAB/capabilities.json"
