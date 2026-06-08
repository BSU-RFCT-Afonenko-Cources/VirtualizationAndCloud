#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation
python3 - <<'PY'
import json,pathlib,subprocess,urllib.request
lab=pathlib.Path('/home/ubuntu/capstone-process-hibernation'); cp=json.loads((lab/'evidence/checkpoint.json').read_text()); now=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status')); cid=subprocess.check_output(['docker','inspect','-f','{{.Id}}','hib-worker'],text=True).strip()
artifacts=['evidence/pre-checkpoint.json','evidence/freeze.json','evidence/checkpoint.json','evidence/restore.json','backups/hib-data.tar.gz','backups/hib-data.tar.gz.sha256','backups/manifest.json','evidence/recovery.json']+cp['artifact_files']
limitations=[]
if cp['mode']=='fallback': limitations=['Docker/CRIU process checkpoint unavailable; see evidence/checkpoint-diagnostics.json']; artifacts.append('evidence/checkpoint-diagnostics.json')
x={'mode':cp['mode'],'definitions':{'freeze':'temporary cgroup suspension retaining live RAM state','checkpoint':'serialized process state artifact, only in CRIU mode','restore':'continuation from process checkpoint or explicitly classified application recovery','backup':'independent copy of persistent files with checksum'},'artifacts':artifacts,'environment_limitations':limitations,'prerequisites':['Docker service available','hib-worker:lab image available','backup checksum valid','host port 18080 available'],'recovery_procedure':['verify selected artifact and checksum','create a new runtime instance using the selected recovery mode','verify endpoint identity and nonzero progress','observe monotonic progress after resume'],'success_criteria':['HTTP /hib-status returns 200','state JSON is valid','progress does not restart from zero','progress continues monotonically'],'final_state':{'instance_id':now['instance_id'],'container_id':cid,'progress':now['progress']},'recovery_level':'process-level' if cp['mode']=='criu' else 'application-level'}
(lab/'runbook.json').write_text(json.dumps(x,indent=2,sort_keys=True))
PY
chown ubuntu:ubuntu "${LAB}/runbook.json"
