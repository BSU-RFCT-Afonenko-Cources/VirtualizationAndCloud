#!/bin/fish

set SOL /home/ubuntu/report.txt

if not test -f $SOL
    echo "Отсутствует файл $SOL"
    exit 1
end

set REPORT (cat $SOL)

if not string match -q "*ubuntu*" "$REPORT"
    echo "В файле report.txt отсутствует запись ubuntu"
    exit 1
end

if not string match -q "*$(hostname)*" "$REPORT"
    echo "В файле report.txt отсутствует запись `$(hostname)`"
    exit 1
end
