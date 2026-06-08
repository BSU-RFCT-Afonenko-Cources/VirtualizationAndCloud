#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation; A="${LAB}/backups/hib-data.tar.gz"; M="${LAB}/backups/manifest.json"; S="${A}.sha256"
[[ -s "${A}" && -f "${M}" && -f "${S}" ]] || { echo "Backup, manifest или checksum отсутствует"; exit 1; }
(cd "${LAB}/backups" && sha256sum -c hib-data.tar.gz.sha256 >/dev/null)
tar -tzf "${A}" | grep -Eq '(^|/)queue.txt$'; tar -tzf "${A}" | grep -Eq '(^|/)progress.json$'; tar -tzf "${A}" | grep -Eq '(^|/)events.log$'
python3 - "${M}" "${A}" "${LAB}/data/progress.json" <<'PY'
import hashlib,json,pathlib,sys,urllib.request
m=json.loads(pathlib.Path(sys.argv[1]).read_text()); a=pathlib.Path(sys.argv[2]); d=json.loads(pathlib.Path(sys.argv[3]).read_text()); now=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status'))
assert m['archive']=='hib-data.tar.gz' and m['sha256']==hashlib.sha256(a.read_bytes()).hexdigest() and m['size_bytes']==a.stat().st_size
assert {'queue.txt','progress.json','events.log'} <= {pathlib.Path(x).name for x in m['files']}
assert m['quiesced'] is True and m['progress']==d['progress']==now['progress'] and m['instance_id']==now['instance_id']
print('Файловый backup согласован и checksum корректен')
PY
