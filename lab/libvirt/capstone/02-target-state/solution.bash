#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Формируем машинно-читаемую декларацию целевого состояния стенда.
D=/home/ubuntu/capstone/02-target-state; ensure_dir "$D"
/usr/bin/cat >"$D/target-state.json" <<'JSON'
{"domains":[{"name":"cap-edge","role":"reverse-proxy"},{"name":"cap-app","role":"api"},{"name":"cap-db","role":"database"}],"networks":["cap-front","cap-back"],"pool":"capstone-pool","volumes":["cap-edge.qcow2","cap-app.qcow2","cap-db.qcow2","cap-db-data.qcow2"],"endpoints":["/health","/version","/orders"]}
JSON
/usr/bin/chown ubuntu:ubuntu "$D/target-state.json"
