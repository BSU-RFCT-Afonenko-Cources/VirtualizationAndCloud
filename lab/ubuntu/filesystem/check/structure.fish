#!/bin/fish

if not test -d /home/ubuntu/filesystem/scripts
    echo "Отсутствует каталог /home/ubuntu/filesystem/scripts"
    exit 1
end

set lines (find /home/ubuntu/filesystem/docs -name "*.txt" | wc -l)

if not test "$lines" = 2
    echo "В каталоге docs нет двух файлов с расширением *.txt"
    exit 1
end

set lines (find /home/ubuntu/filesystem/scripts -name "*.sh" | wc -l)

if not test "$lines" = 1
    echo "В каталоге docs нет файла с расширением *.sh"
    exit 1
end
