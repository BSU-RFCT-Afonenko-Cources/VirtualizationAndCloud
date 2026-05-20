#!/bin/fish

set result (stat -c "%U" /home/lab-share/new.txt)

if not test $status = 0
    echo "Отсутствует файл /home/lab-share/new.txt"
    exit 1
end

if not test $result = labuser
    echo "labuser на является владельцем файла /home/lab-share/new.txt"
    exit 1
end
