#!/bin/fish

if not test -d /home/ubuntu/filesystem/scripts
    exit 1
end

set lines (find /home/ubuntu/filesystem/docs -name "*.txt" | wc -l)

if not  test "$lines" = 2
    exit 1
end

set lines (find /home/ubuntu/filesystem/scripts -name "*.sh" | wc -l)

if not test "$lines" = 1
    exit 1
end
