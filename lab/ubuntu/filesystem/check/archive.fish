#!/bin/fish

if not test -d /home/ubuntu/filesystem/archive
    echo "Отсутствует каталог /home/ubuntu/filesystem/archive"
    exit 1
end

set lines (find /home/ubuntu/filesystem/archive -name "*-bak*" | wc -l)

if not test "$lines" = 1
    echo "В каталоге /archive нет файла `-bak`"
    exit 1
end
