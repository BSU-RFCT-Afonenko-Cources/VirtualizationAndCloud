#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation
E="${LAB}/evidence/checkpoint.json"; D="${LAB}/evidence/checkpoint-diagnostics.json"
[[ -f "${E}" ]] || { echo "Нет evidence/checkpoint.json"; exit 1; }
python3 - "${E}" "${D}" "${LAB}" <<'PY'
import json,pathlib,sys
p=pathlib.Path(sys.argv[1]); x=json.loads(p.read_text()); lab=pathlib.Path(sys.argv[3])
assert x.get('mode') in ('criu','fallback')
assert int(x.get('artifact_size_bytes',0))>0 and x.get('instance_id') and int(x.get('progress',-1))>=0
files=x.get('artifact_files'); assert isinstance(files,list) and files
for item in files:
    assert (lab/item).exists(), f'Artifact отсутствует: {item}'
if x['mode']=='fallback':
    d=json.loads(pathlib.Path(sys.argv[2]).read_text())
    assert d.get('mode')=='fallback' and d.get('reason')
    for key in ('docker','criu','kernel','cgroup'):
        assert key in d, f'Нет diagnostics.{key}'
    f=json.loads((lab/'checkpoints/fallback-state.json').read_text())
    assert f.get('classification')=='application-state-not-process-checkpoint'
else:
    assert any('checkpoint' in f or f.endswith('.img') for f in files)
print('Checkpoint artifact или доказанный fallback корректен')
PY
