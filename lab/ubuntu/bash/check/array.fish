#!/bin/fish

set SOL /home/ubuntu/bash/array.sh

if not test (bash "$SOL" a b apple) = "apple"
    exit 1
end

if not test (bash "$SOL" one three elephant cat) = "elephant"
    exit 1
end
