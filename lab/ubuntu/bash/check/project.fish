#!/bin/fish

set SOL /home/ubuntu/bash/project.sh

if not test -f "$SOL"
    echo "Отсутствует файл $SOL"
    exit 1
end

set tmp (mktemp -d)
cd "$tmp"

function clear_tmp --on-signal fish_exit
    if set -q tmp
        echo cd ~
        rm -rf $tmp
    end
end

bash "$SOL" project

for f in project{src,data,reports}
    if not test -d $f
        echo "В проекте отсутствует каталог $f"
        exit 1
    end
end

if not test -f project/README.md
    echo "В проекте отсутствует файл README.md"
    exit 1
end

if not string match -q "*project*" (cat project/README.md)
    echo "В файле README.md отсутствует запись `project`"
    exit 1
end
