#!/bin/fish

set tmp (mktemp -d)
set SOL /home/ubuntu/bash/project.sh

cd "$tmp"

bash "$SOL" project

if not test -d project/src
    exit 1
end

if not test -d project/data
    exit 1
end

if not test -d project/reports
    exit 1
end

if not test -f project/README.md
    exit 1
end

if not string match -q "*project*" (cat project/README.md)
    exit 1
end
