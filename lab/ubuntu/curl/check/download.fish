#!/bin/fish

if not test -f /home/ubuntu/curl/lines.txt
    echo "Отсутствует файл /home/ubuntu/curl/lines.txt"
    exit 1
end

if not string match -q "*"(curl -s https://ubuntu.com | wc -l)"*" (cat /home/ubuntu/curl/lines.txt)
    echo "Неверное число строк"
    echo "Используйте silent mode `curl -s`"
    exit 1
end
