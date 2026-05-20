#!/bin/fish

set SOL /home/ubuntu/bash/array.sh

if not test (bash "$SOL" a b apple) = "apple"
    echo "Неверное решение array.sh"
    exit 1
end

if not test (bash "$SOL" one three elephant cat) = "elephant"
    echo "Неверное решение array.sh"
    exit 1
end
