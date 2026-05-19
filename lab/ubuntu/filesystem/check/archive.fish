#!/bin/fish

set lines (find /home/ubuntu/filesystem/archive -name "*-bak*" | wc -l)

if not test "$lines" = 1
    exit 1
end
