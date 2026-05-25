#!/bin/fish

set GUEST_SCRIPT (cat guest.sh | jq -Rrs 'tojson')

set GUEST_PID (virsh qemu-agent-command testvm  '{
    "execute" : "guest-exec",
    "arguments" : {
        "path" : "/bin/sh",
        "arg" : ["-c", '"$GUEST_SCRIPT"'],
        "capture-output" : true}
}' | jq '.return')

set RETURN (virsh qemu-agent-command testvm '{
    "execute" : "guest-exec-status",
    "arguments" : '"$GUEST_PID"'
}')

echo $RETURN | jq -r '.return."out-data"' | base64 -d
