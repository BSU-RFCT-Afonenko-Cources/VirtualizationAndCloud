#!/bin/fish

if not (cat /home/ubuntu/package/curl.txt) = (apt show curl)
    exit 1
end
