#!/bin/fish

if not test -d /home/lab-share
    echo "Нет каталога /home/lab-share"
    exit 1
end

if not string match -q labuser (stat -c "%U" /home/lab-share)
    echo "Пользователь labuser не является владельцем /lab-share"
    exit 1
end

if not string match -q labuser (stat -c "%U" /home/lab-share)
    echo "Группа labgroup не является владельцем /home/lab-share"
    exit 1
end

if not test (string sub --start=-3 (stat -c %A /home/lab-share)) = 'rwx'
    echo "Неверные разрешения каталога /home/lab-share"
    exit 1
end
