#!/bin/fish

set tmp (mktemp -d)
cd tmp

set SOL /home/ubuntu/bash/backup.sh

echo hello > file.txt

bash "$SOL" file.txt

if not test -f file.txt.bak
  exit 1
end

if not test (cat file.txt.bak) = hello
    exit 1
end

set out (bash "$SOL" "no.txt" 2>&1)

if not $status = 1
  exit 1
end

if not "$out" = missing
  exit 1
end
