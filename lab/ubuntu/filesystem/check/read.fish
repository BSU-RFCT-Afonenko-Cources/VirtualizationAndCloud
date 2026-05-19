#!/bin/fish

for f in (find /home/ubuntu/filesystem/docs -name "*.txt")
    set perm (stat -c %A "$f")
    if not test "$perm" = "-rw---x---"
        echo "Incorrect docs file permission"
        exit 1
    end
end
