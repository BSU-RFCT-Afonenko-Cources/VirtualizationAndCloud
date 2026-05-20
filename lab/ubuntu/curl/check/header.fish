#!/bin/fish

if not test -f /home/ubuntu/curl/header.txt
    echo "Отсутствует файл /home/ubuntu/curl/header.txt"
    exit 1
end

set headers (cat /home/ubuntu/curl/header.txt)

if not test "$headers" = "$(curl -sI https://ubuntu.com)"
    echo "Файл header.txt содержит невеные заголовки"
    if string match -q "*Xferd*" "$headers"
        echo "Используйте silent mode `curl -s`"
    end
    exit 1
end

