#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/cr-lab
/usr/bin/install -d -o ubuntu -g ubuntu "$LAB/evidence"
/usr/bin/python3 - <<'PY'
import json
p='/home/ubuntu/cr-lab/evidence/terms.json'
data={
 'freeze': {'keeps_process_memory': True, 'creates_process_image_files': False, 'keeps_filesystem_data': False, 'result': 'same-stopped-process'},
 'checkpoint': {'keeps_process_memory': True, 'creates_process_image_files': True, 'keeps_filesystem_data': False, 'result': 'process-image-files'},
 'restore': {'keeps_process_memory': True, 'creates_process_image_files': False, 'keeps_filesystem_data': False, 'result': 'continued-process'},
 'filesystem_snapshot': {'keeps_process_memory': False, 'creates_process_image_files': False, 'keeps_filesystem_data': True, 'result': 'point-in-time-filesystem'},
 'backup': {'keeps_process_memory': False, 'creates_process_image_files': False, 'keeps_filesystem_data': True, 'result': 'independent-data-copy'}}
with open(p,'w',encoding='utf-8') as f: json.dump(data,f,ensure_ascii=False,indent=2)
PY
/bin/chown ubuntu:ubuntu "$LAB/evidence/terms.json"
