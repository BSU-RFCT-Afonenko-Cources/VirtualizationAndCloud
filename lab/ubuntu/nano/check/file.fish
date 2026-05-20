#!/bin/fish

if not test -f /home/ubuntu/nano/notes.txt
    echo "Отсутствует файл /home/ubuntu/nano/notes.txt"
    exit 1
end

set NOTES (cat /home/ubuntu/nano/notes.txt)

if not string match -q "*Ubuntu Server*" "$NOTES"
    echo "В файле notes.txt нет записи `Ubuntu Server`"
    exit 1
end

if not string match -q "*Bash*" "$NOTES"
    echo "В файле notes.txt нет записи `Bash`"
    exit 1
end

if not string match -q "*Filesystem*" "$NOTES"
    echo "В файле notes.txt нет записи `Filesystem`"
    exit 1
end
