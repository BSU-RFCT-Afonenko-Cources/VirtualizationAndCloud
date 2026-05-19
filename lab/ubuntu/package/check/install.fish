#!/bin/fish

if not (tree /home/ubuntu/bash) = (cat /home/ubuntu/package/tree.txt)
    exit 1
end
