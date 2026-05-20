#!/bin/fish

if not test -f /home/ubuntu/package/curl.txt
    echo "Нет такого файла /home/ubuntu/package/curl.txt"
end

if not (cat /home/ubuntu/package/curl.txt) = (apt show curl)
    echo "Файл curl.txt не содержит вывод команы `apt show curl`"
    exit 1
end
