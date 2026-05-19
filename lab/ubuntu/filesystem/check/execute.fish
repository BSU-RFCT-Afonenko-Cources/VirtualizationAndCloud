#!/bin/fish

set perm (stat -c %A (find /home/ubuntu/filesystem/scripts -name "*.sh" | head -n 1) )

if not test "$perm" = "-rwxr-xr--"
    echo "Incorrect script file permission"
    exit 1
end
