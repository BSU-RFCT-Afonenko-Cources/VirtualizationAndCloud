#!/bin/fish

set result (groups labuser)

if not test $status = 0
    echo "Нет пользователя labuser"
    exit 1
end

if not string match -q "*labgroup*" "$result"
    echo "Пользователь labuser не входит в группу labgroup"
    exit 1
end
