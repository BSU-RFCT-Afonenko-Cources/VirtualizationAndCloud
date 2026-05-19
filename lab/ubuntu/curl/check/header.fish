#!/bin/fish

if not (cat /home/ubuntu/curl/header.txt) = (curl -I https://ubuntu.com)
    exit 1
end

