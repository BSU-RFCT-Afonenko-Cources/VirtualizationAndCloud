#!/bin/fish

if not test -f /home/ubuntu/package/tree.txt
    echo "Нет такого файла /home/ubuntu/package/tree.txt"
    exit 1
end

if not (tree /home/ubuntu/bash) = (cat /home/ubuntu/package/tree.txt)
    echo "Файл tree.txt не содержит вывод команды `tree /home/ubuntu/bash`"
    exit 1
end
