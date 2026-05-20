#!/bin/fish

if not test -f /home/ubuntu/report.txt
    echo "Отсутствует файл /home/ubuntu/report.txt"
    exit 1
end

set REPORT (cat /home/ubuntu/report.txt)

if not string match -q "*$USER*" "$REPORT"
    echo "В файле report.txt отсутствует запись `$USER`"
    exit 1
end

if not string match -q "*"(hostname)"*" "$REPORT"
    echo "В файле report.txt отсутствует запись `$(hostname)`"
    exit 1
end
