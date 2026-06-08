#!/bin/bash
source /usr/local/lib/ns-lab/check-common.bash
f=/home/ubuntu/ns-lab/evidence/01-inventory.json
require_json "$f"
/usr/bin/jq -e '(.shell_pid|type)=="number" and (.host_hostname|length)>0 and (.observed_types|length)>=2 and (.processes|type)=="array" and (.processes|length)>=1 and all(.processes[]; (.namespaces|type)=="object")' "$f" >/dev/null || fail "evidence не содержит обязательную инвентаризацию"
/usr/bin/jq -e '[.processes[].namespaces[]] | map(select(type=="string" and test("^[a-z_]+:\\[[0-9]+\\]$"))) | length >= 2' "$f" >/dev/null || fail "namespace handles пусты или имеют неверный формат"
pass "инвентаризация namespaces сохранена"
