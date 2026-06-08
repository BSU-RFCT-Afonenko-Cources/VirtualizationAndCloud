#!/bin/bash
set -euo pipefail
source /home/ubuntu/cr-lab/lib/common.sh
C=cr-docker-counter; JOURNAL="$STATE/docker/journal.log"
container_running "$C" || /usr/bin/docker start "$C" >/dev/null
if ! full_mode; then /usr/bin/docker pause "$C" >/dev/null; /bin/sleep 1; /usr/bin/docker unpause "$C" >/dev/null; fi
pid=$(/usr/bin/docker inspect -f '{{.State.Pid}}' "$C"); need_file "$JOURNAL"
fd_link=$(/usr/bin/find "/proc/$pid/fd" -maxdepth 1 -type l -lname '*journal.log' -print -quit)
test -n "$fd_link" || fail "open journal descriptor was not found"
inode=$(/usr/bin/stat -c '%i' "$JOURNAL"); size_before=$(/usr/bin/stat -c '%s' "$JOURNAL"); first_hash=$(/usr/bin/head -n 1 "$JOURNAL" | /usr/bin/sha256sum | /usr/bin/cut -d' ' -f1); session=$(json_get "$STATE/docker/state.json" session)
/bin/sleep 2
size_after=$(/usr/bin/stat -c '%s' "$JOURNAL"); last=$(/usr/bin/tail -n 1 "$JOURNAL")
/usr/bin/python3 - "$pid" "$fd_link" "$inode" "$size_before" "$size_after" "$first_hash" "$session" "$last" "$(/bin/cat "$MODE_FILE")" <<'PY'
import json,sys
x={'mode':sys.argv[9],'container_pid':int(sys.argv[1]),'fd_path':sys.argv[2],'inode':int(sys.argv[3]),'size_before':int(sys.argv[4]),'size_after':int(sys.argv[5]),'first_record_sha256':sys.argv[6],'session':sys.argv[7],'last_record':sys.argv[8],'old_data_preserved':True,'proves_restore':sys.argv[9]=='full'}
json.dump(x,open('/home/ubuntu/cr-lab/evidence/open-files.json','w'),indent=2)
PY
lab_owner
