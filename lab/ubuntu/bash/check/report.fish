#!/bin/fish

set REPORT (cat /home/ubuntu/report.txt)

if not string match -q "*$USER*" "$REPORT"
    exit 1
end

if not string match -q "*"(hostname)"*" "$REPORT"
    exit 1
end
