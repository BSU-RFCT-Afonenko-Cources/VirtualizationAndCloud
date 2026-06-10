#!/bin/fish

if not test -d /home/ubuntu/user/lab-share
    echo "Нет каталога /home/ubuntu/user/lab-share"
    exit 1
end

if not string match -q labuser (stat -c "%U" /home/ubuntu/user/lab-share)
    echo "Пользователь labuser не является владельцем /lab-share"
    exit 1
end

if not string match -q labuser (stat -c "%U" /home/ubuntu/user/lab-share)
    echo "Группа labgroup не является владельцем /home/ubuntu/user/lab-share"
    exit 1
end

if not test (string sub --start=-3 (stat -c %A /home/ubuntu/user/lab-share)) = 'rwx'
    echo "Неверные разрешения каталога /home/ubuntu/user/lab-share"
    exit 1
end
