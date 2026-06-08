#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation
curl -fsS -X POST http://127.0.0.1:18080/quiesce >/dev/null
sleep 1
STATUS=$(curl -fsS http://127.0.0.1:18080/hib-status)
INSTANCE=$(python3 -c 'import json,sys; print(json.load(sys.stdin)["instance_id"])' <<<"${STATUS}")
PROGRESS=$(python3 -c 'import json,sys; print(json.load(sys.stdin)["progress"])' <<<"${STATUS}")
MODE=fallback
REASON=""
if command -v criu >/dev/null 2>&1 && docker checkpoint create --checkpoint-dir "${LAB}/checkpoints" hib-worker hib-checkpoint >"${LAB}/evidence/checkpoint-command.txt" 2>&1; then
  MODE=criu
else
  REASON=$(tail -c 2000 "${LAB}/evidence/checkpoint-command.txt" 2>/dev/null || true)
  [[ -n "${REASON}" ]] || REASON="CRIU executable or Docker checkpoint support is unavailable"
fi
python3 - "${MODE}" "${REASON}" "${INSTANCE}" "${PROGRESS}" <<'PY'
import json,os,pathlib,platform,shutil,subprocess,sys,time
lab=pathlib.Path('/home/ubuntu/capstone-process-hibernation'); mode,reason,instance,progress=sys.argv[1:]
def out(cmd):
    p=subprocess.run(cmd,text=True,capture_output=True); return {'exit_code':p.returncode,'stdout':p.stdout[-2000:],'stderr':p.stderr[-2000:]}
if mode=='fallback':
    state={'classification':'application-state-not-process-checkpoint','instance_id':instance,'progress':int(progress),'progress_file':'data/progress.json','created_at':time.time()}
    (lab/'checkpoints/fallback-state.json').write_text(json.dumps(state,indent=2,sort_keys=True))
    diagnostics={'mode':'fallback','reason':reason,'docker':out(['docker','info']),'criu':out(['criu','--version']) if shutil.which('criu') else {'available':False},'kernel':{'release':platform.release()},'cgroup':{'version':'v2' if pathlib.Path('/sys/fs/cgroup/cgroup.controllers').exists() else 'v1'},'created_at':time.time()}
    (lab/'evidence/checkpoint-diagnostics.json').write_text(json.dumps(diagnostics,indent=2,sort_keys=True))
    artifacts=['checkpoints/fallback-state.json']
else:
    checkpoint=lab/'checkpoints/hib-checkpoint'
    files=sorted(p for p in checkpoint.rglob('*') if p.is_file())
    manifest=lab/'checkpoints/hib-checkpoint-manifest.txt'; manifest.write_text('\n'.join(str(p.relative_to(lab)) for p in files))
    artifacts=['checkpoints/hib-checkpoint-manifest.txt']+[str(p.relative_to(lab)) for p in files]
size=sum((lab/a).stat().st_size for a in artifacts)
e={'mode':mode,'artifact_size_bytes':size,'artifact_files':artifacts,'instance_id':instance,'progress':int(progress),'created_at':time.time()}
(lab/'evidence/checkpoint.json').write_text(json.dumps(e,indent=2,sort_keys=True))
PY
chown -R ubuntu:ubuntu "${LAB}/checkpoints" "${LAB}/evidence"
