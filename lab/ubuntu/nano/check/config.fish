#!/bin/fish

if not test -f /home/ubuntu/nano/app.conf
    echo "Нет такого файла /home/ubuntu/nano/app.conf"
    exit 1
end

if not string match -q "*enabled = yes*" (cat /home/ubuntu/nano/app.conf)
    echo "В файле app.conf отсутствует запись `enabled = yes`"
    exit 1
end
