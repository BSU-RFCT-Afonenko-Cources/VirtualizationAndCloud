#!/bin/fish

if not string match -q "*enabled = yes*" (cat /home/ubuntu/nano/app.conf)
    exit 1
end
