#!/bin/fish

for f in (find /home/ubuntu/filesystem/docs -name "*.txt")
    set perm (stat -c %A "$f")
    if not test "$perm" = "-rw---x---"
        echo "У файла $f назначены неверные права"
        exit 1
    end
end
