#!/bin/fish

if not test -f /home/ubuntu/nano/notes.txt
    exit 1
end

set NOTES (cat /home/ubuntu/nano/notes.txt)

if not string match -q "*Ubuntu Server*" "$NOTES"
    exit 1
end

if not string match -q "*Bash*" "$NOTES"
    exit 1
end

if not string match -q "*Filesystem*" "$NOTES"
    exit 1
end
