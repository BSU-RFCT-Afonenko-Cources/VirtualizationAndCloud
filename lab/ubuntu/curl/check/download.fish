#!/bin/fish

if not string match -q "*"(curl -s https://ubuntu.com | wc -l)"*" (cat /home/ubuntu/curl/lines.txt)
    exit 1
end
